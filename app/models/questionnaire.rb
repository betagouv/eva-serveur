class Questionnaire < ApplicationRecord
  include Fichier

  LIVRAISON_SANS_REDACTION = "livraison_sans_redaction"
  LIVRAISON_AVEC_REDACTION = "livraison_expression_ecrite"
  SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT_SANTE = "sociodemographique_autopositionnement_sante"
  SOCIODEMOGRAPHIQUE_SANTE = "sociodemographique_sante"
  SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT = "sociodemographique_autopositionnement"
  SOCIODEMOGRAPHIQUE = "sociodemographique"
  AUTOPOSITIONNEMENT = "autopositionnement"

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


  def livraison_sans_redaction?
    nom_technique == Questionnaire::LIVRAISON_SANS_REDACTION
  end

  def questions_par_type
    questions.group_by(&:type)
  end

  def nom_fichier_export
    nom_fichier_horodate("export-questionnaire-#{nom_technique}", "zip")
  end
end
