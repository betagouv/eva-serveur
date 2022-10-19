# frozen_string_literal: true

class SituationConfiguration < ApplicationRecord
  belongs_to :situation
  belongs_to :questionnaire, optional: true

  delegate :libelle, :nom_technique, :questionnaire_entrainement_id, to: :situation
  delegate :nom_technique, to: :questionnaire_utile, prefix: :questionnaire
  delegate :livraison_sans_redaction?, to: :situation, allow_nil: true

  acts_as_list scope: %i[campagne_id parcours_type_id]

  validates :situation_id, uniqueness: { scope: %i[campagne_id parcours_type_id] }

  acts_as_paranoid

  def questionnaire_utile
    @questionnaire_utile ||= (questionnaire || situation.questionnaire)
  end

  class << self
    def questionnaire_inclus?(situations_configurations, questionnaire)
      situations_configurations.any? do |sc|
        next if sc.questionnaire_utile.blank?

        sc.questionnaire_nom_technique == questionnaire
      end
    end

    def ids_situations(id_campagne, noms_techniques)
      SituationConfiguration.joins(:situation)
                            .where(campagne_id: id_campagne)
                            .where(situations: { nom_technique: noms_techniques })
                            .pluck(:situation_id)
    end
  end
end
