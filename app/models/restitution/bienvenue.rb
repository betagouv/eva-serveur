# frozen_string_literal: true

module Restitution
  class Bienvenue < Base
    NOM_TECHNIQUE = 'bienvenue'

    def questions_reponses
      @questions_reponses ||= QuestionsReponses.new(evenements,
                                                    campagne.questionnaire_pour(situation))
    end

    def questions_et_reponses(type_qcm = nil)
      questions_reponses.questions_et_reponses(type_qcm)
    end
  end
end
