# frozen_string_literal: true

module Restitution
  class QuestionsReponses
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    def initialize(evenements, questionnaire)
      @evenements = evenements
      @questionnaire = questionnaire
    end

    def questions_et_reponses(type_qcm = nil)
      questions_repondues
        .map { |question| [question, choix_repondu(question)] }
        .select { |q_et_r| type_qcm.nil? || q_et_r[0].type_qcm == type_qcm.to_s }
    end

    def reponses
      @evenements.find_all { |e| e.nom == EVENEMENT[:REPONSE] }
    end

    def questions
      @questionnaire.questions
    end

    def questions_repondues
      questions_ids = reponses.collect { |r| r.donnees['question'] }
      questions.where(id: questions_ids)
    end

    def choix_repondu(question)
      evenement_reponse = reponses.find do |evenement|
        evenement.donnees['question'] == question.id
      end
      return if evenement_reponse.blank?

      reponse = evenement_reponse.donnees['reponse']
      question.is_a?(QuestionQcm) ? question.choix.find(reponse) : reponse
    end
  end
end
