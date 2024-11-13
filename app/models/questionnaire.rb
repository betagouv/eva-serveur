# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  LIVRAISON_SANS_REDACTION = 'livraison_sans_redaction'
  LIVRAISON_AVEC_REDACTION = 'livraison_expression_ecrite'
  SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT = 'sociodemographique_autopositionnement'
  SOCIODEMOGRAPHIQUE = 'sociodemographique'
  AUTOPOSITIONNEMENT = 'autopositionnement'

  has_many :questionnaires_questions, lambda {
                                        order(position: :asc)
                                      }, dependent: :destroy
  has_many :questions, through: :questionnaires_questions

  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true

  accepts_nested_attributes_for :questionnaires_questions, allow_destroy: true

  acts_as_paranoid

  def display_name
    libelle
  end

  def self.livraison_avec_redaction
    find_by(nom_technique: LIVRAISON_AVEC_REDACTION)
  end

  def self.bienvenue_avec_autopositionnement
    find_by(nom_technique: SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT)
  end

  def livraison_sans_redaction?
    nom_technique == Questionnaire::LIVRAISON_SANS_REDACTION
  end

  def questions_par_type
    questions.group_by(&:type)
  end
end
