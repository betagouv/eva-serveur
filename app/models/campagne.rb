# frozen_string_literal: true

class Campagne < ApplicationRecord
  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true

  def display_name
    libelle
  end
end
