# frozen_string_literal: true

class Structure < ApplicationRecord
  belongs_to :structure_referente, optional: true, class_name: 'Structure'

  validates :nom, presence: true

  auto_strip_attributes :nom, squish: true

  geocoded_by :code_postal, state: :region, params: { countrycodes: 'fr' } do |obj, resultats|
    if (resultat = resultats.first)
      obj.region = resultat.state
      obj.latitude = resultat.latitude
      obj.longitude = resultat.longitude
    end
  end

  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }

  scope :joins_evaluations_et_groupe, lambda {
    joins('LEFT OUTER JOIN comptes ON structures.id = comptes.structure_id')
      .joins('LEFT OUTER JOIN campagnes ON comptes.id = campagnes.compte_id')
      .joins('LEFT OUTER JOIN evaluations ON campagnes.id = evaluations.campagne_id')
      .group('structures.id')
      .uniq!(:group)
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

  scope :sans_campagne, lambda {
    ids = Campagne.joins(:compte).select('structure_id')
    where.not(id: ids)
  }
  scope :non_activees, -> { par_nombre_d_evaluations 'BETWEEN 1 AND 3' }
  scope :activees, -> { par_nombre_d_evaluations '> 3' }
  scope :actives, -> { activees.par_derniere_evaluation('> ?', 2.months.ago).uniq!(:group) }
  scope :inactives, lambda {
    activees.par_derniere_evaluation('BETWEEN ? AND ?', 6.months.ago, 2.months.ago).uniq!(:group)
  }
  scope :abandonnistes, -> { activees.par_derniere_evaluation('< ?', 6.months.ago).uniq!(:group) }

  scope :avec_nombre_evaluations_et_date_derniere_evaluation, lambda {
    joins_evaluations_et_groupe
      .select('structures.*,
              COUNT(evaluations.id) AS nombre_evaluations,
              MAX(evaluations.created_at) AS date_derniere_evaluation')
  }

  alias_attribute :display_name, :nom

  def effectif
    Compte.where(structure: self).count
  end
end
