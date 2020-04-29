# frozen_string_literal: true

module Restitution
  class Questions < Base
    delegate :questions_et_reponses, :reponses, :choix_repondu, :questions, to: :questions_reponses

    def termine?
      super || reponses.size == questions.size
    end

    def efficience
      nil
    end

    def questions_reponses
      @questions_reponses ||= QuestionsReponses.new(evenements, campagne.questionnaire)
    end
  end
end
