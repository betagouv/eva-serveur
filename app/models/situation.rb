# frozen_string_literal: true

class Situation < ApplicationRecord
  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true
  belongs_to :questionnaire, optional: true
  belongs_to :questionnaire_entrainement, optional: true, class_name: 'Questionnaire'

  delegate :livraison_sans_redaction?, to: :questionnaire, allow_nil: true

  BIENVENUE = 'bienvenue'
  CAFE_DE_LA_PLACE = 'cafe_de_la_place'
  PLAN_DE_LA_VILLE = 'plan_de_la_ville'

  acts_as_paranoid

  def display_name
    libelle
  end

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id)
  end
end
