# frozen_string_literal: true

class Question < ApplicationRecord
  validates :intitule, presence: true

  validates :intitule, presence: true
  validates :libelle, presence: true

  def display_name
    libelle
  end
end
