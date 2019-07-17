# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  has_and_belongs_to_many :questions

  validates :libelle, presence: true

  def display_name
    libelle
  end
end
