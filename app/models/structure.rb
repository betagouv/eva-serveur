# frozen_string_literal: true

class Structure < ApplicationRecord
  TYPES_STRUCTURES = %w[
    mission_locale pole_emploi SIAE service_insertion_collectivite CRIA
    organisme_formation orientation_scolaire cap_emploi e2c SMA autre
  ].freeze

  validates :nom, :code_postal, :type_structure, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + ['non_communique']) }

  auto_strip_attributes :nom, :code_postal, squish: true

  geocoded_by :code_postal, state: :region, params: { countrycodes: 'fr' } do |obj, resultats|
    if (resultat = resultats.first)
      obj.region = resultat.state
      obj.latitude = resultat.latitude
      obj.longitude = resultat.longitude
    end
  end

  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }

  scope :joins_evaluations_et_groupe, lambda {
    joins('INNER JOIN comptes ON structures.id = comptes.structure_id')
      .joins('INNER JOIN campagnes ON comptes.id = campagnes.compte_id')
      .joins('INNER JOIN evaluations ON campagnes.id = evaluations.campagne_id')
      .group('structures.id')
  }
  scope :par_nombre_d_evaluations, lambda { |condition_nb_evaluations|
    joins_evaluations_et_groupe
      .having("COUNT(evaluations.id) #{condition_nb_evaluations}")
  }
  scope :par_derniere_evaluation, lambda { |*condition_date|
    condition_date[0] = "MAX(evaluations.created_at) #{condition_date[0]}"
    joins_evaluations_et_groupe
      .having(*condition_date)
  }

  scope :pas_vraiment_utilisatrices, lambda {
    ids = Evaluation.joins(campagne: { compte: :structure })
                    .select('structures.id')
    where.not(id: ids)
  }

  scope :non_activees, -> { par_nombre_d_evaluations 'BETWEEN 1 AND 3' }
  scope :activees, -> { par_nombre_d_evaluations '> 3' }
  scope :actives, -> { activees.par_derniere_evaluation('> ?', 2.months.ago).uniq!(:group) }
  scope :inactives, lambda {
    activees.par_derniere_evaluation('BETWEEN ? AND ?', 6.months.ago, 2.months.ago).uniq!(:group)
  }
  scope :abandonnistes, -> { activees.par_derniere_evaluation('< ?', 6.months.ago).uniq!(:group) }

  def display_name
    nom
  end

  def effectif
    Compte.where(structure: self).count
  end

  def cible_evaluation
    case type_structure
    when 'mission_locale', 'orientation_scolaire', 'e2c', 'SMA'
      'jeunes'
    when 'SIAE', 'cap_emploi' then "demandeurs d'emploi"
    when 'service_insertion_collectivite' then 'usagers'
    when 'organisme_formation' then 'stagiaires'
    else
      'bénéficiaires'
    end
  end
end
