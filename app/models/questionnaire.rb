# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  has_many :questionnaires_questions, -> { order(position: :asc) }, dependent: :destroy

  validates :libelle, presence: true

  accepts_nested_attributes_for :questionnaires_questions, allow_destroy: true

  def display_name
    libelle
  end
end
