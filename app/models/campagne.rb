# frozen_string_literal: true

class Campagne < ApplicationRecord
  has_many :evaluations
  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true

  def display_name
    libelle
  end
end
