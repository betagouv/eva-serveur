# frozen_string_literal: true

class Structure < ApplicationRecord
  TYPES_STRUCTURES = %w[
    mission_locale pole_emploi SIAE centre_action_social CRIA
    organisme_formation orientation_scolaire cap_emploi e2c autre
  ].freeze

  validates :nom, :code_postal, :type_structure, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + ['non_communique']) }

  geocoded_by :code_postal, params: { countrycodes: 'fr' }

  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }

  def display_name
    nom
  end
end
