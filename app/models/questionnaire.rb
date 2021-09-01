# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  has_many :questionnaires_questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :questions, through: :questionnaires_questions

  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true

  accepts_nested_attributes_for :questionnaires_questions, allow_destroy: true

  def display_name
    libelle
  end
end
