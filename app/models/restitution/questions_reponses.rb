# frozen_string_literal: true

module Restitution
  class QuestionsReponses
    def initialize(evenements, questionnaire)
      @evenements = evenements
      @questionnaire = questionnaire
    end

    def questions_et_reponses(type_qcm = nil)
      questions_repondues
        .map { |question| [question, choix_repondu(question)] }
        .select { |q_et_r| type_qcm.nil? || q_et_r[0].type_qcm == type_qcm.to_s }
    end

    def questions_redaction
      @questions_redaction ||= questions_et_reponses.select do |q, r|
        [q, r] if q.is_a?(QuestionRedactionNote)
      end
    end

    def reponses
      @evenements.find_all { |e| e.nom == MetriquesHelper::EVENEMENT[:REPONSE] }
    end

    def questions
      @questionnaire.questions
    end

    def questions_repondues
      questions_ids = reponses.collect { |r| r.donnees['question'] }
      questions.where(id: questions_ids, type: 'QuestionQcm').includes(:choix) +
        questions.where(id: questions_ids).where.not(type: 'QuestionQcm')
    end

    def choix_repondu(question)
      evenement_reponse = reponses.find do |evenement|
        evenement.donnees['question'] == question.id
      end
      return if evenement_reponse.blank?

      reponse = evenement_reponse.donnees['reponse']
      question.is_a?(QuestionQcm) ? question.choix.detect { |c| c.id == reponse } : reponse
    end
  end
end
