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

  class << self
    def auto_positionnement_inclus?(situations_configurations)
      situations_configurations.any? do |sc|
        if sc.questionnaire.present?
          sc.questionnaire.nom_technique == Eva::QUESTIONNAIRE_AUTO_POSITIONNEMENT
        else
          false
        end
      end
    end

    def expression_ecrite_incluse?(situations_configurations)
      situations_configurations.any? do |sc|
        if sc.questionnaire.present?
          sc.questionnaire.nom_technique == Eva::QUESTIONNAIRE_EXPRESSION_ECRITE
        else
          false
        end
      end
    end
  end
end
