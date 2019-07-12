# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  validates :libelle, :questions, presence: true

  def display_name
    libelle
  end
end
