# frozen_string_literal: true

class Situation < ApplicationRecord
  OPTIONNELLES = %w[plan_de_la_ville bienvenue livraison_expression_ecrite].freeze

  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true
  belongs_to :questionnaire, optional: true
  belongs_to :questionnaire_entrainement, optional: true, class_name: 'Questionnaire'

  def display_name
    libelle
  end

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id)
  end
end
