# frozen_string_literal: true

class SituationConfiguration < ApplicationRecord
  belongs_to :situation
  belongs_to :questionnaire, optional: true

  delegate :libelle, :nom_technique, :questionnaire_entrainement_id, to: :situation

  acts_as_list scope: %i[campagne_id parcours_type_id]

  validates :situation_id, uniqueness: { scope: %i[campagne_id parcours_type_id] }

  def questionnaire_utile
    @questionnaire_utile ||= (questionnaire || situation.questionnaire)
  end
end
