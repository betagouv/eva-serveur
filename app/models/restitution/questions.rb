# frozen_string_literal: true

module Restitution
  class Questions < Base
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    def termine?
      super || reponses.size == questions.size
    end

    def questions_et_reponses
      questions_repondues
        .map do |question|
        {
          question: question,
          reponse: trouve_reponse(question.id)
        }
      end
    end

    def reponses
      evenements.find_all { |e| e.nom == EVENEMENT[:REPONSE] }
    end

    def choix_repondu(question)
      question_et_reponse = questions_et_reponses.find do |question_reponse|
        question_reponse[:question].id == question.id
      end
      return unless question_et_reponse

      question_et_reponse[:question].choix.find(question_et_reponse[:reponse])
    end

    def efficience
      nil
    end

    private

    def questions
      campagne.questionnaire.questions
    end

    def questions_repondues
      questions_ids = reponses.collect { |r| r.donnees['question'] }
      questions.where(id: questions_ids)
    end

    def trouve_reponse(question_id)
      reponses.find do |evenement|
        evenement.donnees['question'] == question_id
      end.donnees['reponse']
    end
  end
end
