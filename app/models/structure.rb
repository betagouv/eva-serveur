# frozen_string_literal: true

class Structure < ApplicationRecord
  TYPES_STRUCTURES = %w[
    mission_locale pole_emploi SIAE service_insertion_collectivite CRIA
    organisme_formation orientation_scolaire cap_emploi e2c SMA autre
  ].freeze

  validates :nom, :code_postal, :type_structure, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + ['non_communique']) }

  geocoded_by :code_postal, params: { countrycodes: 'fr' }

  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }

  scope :par_nombre_d_evaluations, lambda { |condition_nb_evaluations|
    joins('INNER JOIN comptes ON structures.id = comptes.structure_id')
      .joins('INNER JOIN campagnes ON comptes.id = campagnes.compte_id')
      .group('structures.id')
      .having("SUM(campagnes.nombre_evaluations) #{condition_nb_evaluations}")
  }
  scope :pas_vraiment_utilisatrices, -> { par_nombre_d_evaluations '= 0' }
  scope :non_activees, -> { par_nombre_d_evaluations 'BETWEEN 1 AND 3' }
  scope :actives, -> { par_nombre_d_evaluations '> 3' }

  def display_name
    nom
  end
end
