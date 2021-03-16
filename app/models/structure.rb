# frozen_string_literal: true

class Structure < ApplicationRecord
  validates :nom, :code_postal, presence: true

  geocoded_by :code_postal, params: { countrycodes: 'fr' }

  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }

  def display_name
    nom
  end
end
