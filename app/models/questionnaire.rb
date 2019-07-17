# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  validates :libelle, presence: true

  def display_name
    libelle
  end
end
