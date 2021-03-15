# frozen_string_literal: true

class Structure < ApplicationRecord
  validates :nom, :code_postal, presence: true

  geocoded_by :code_postal

  after_validation :geocode

  def display_name
    nom
  end
end
