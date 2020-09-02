# frozen_string_literal: true

module Restitution
  class Bienvenue < Base
    NOM_TECHNIQUE = 'bienvenue'

    def questions_et_reponses(type_qcm = nil)
      qr = QuestionsReponses.new(evenements, situation.questionnaire)
      qr.questions_et_reponses(type_qcm)
    end
  end
end
