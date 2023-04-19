# frozen_string_literal: true

module Restitution
  class QuestionsReponses
    def initialize(evenements)
      @evenements = evenements
    end

    def questions_et_reponses(type_qcm = nil)
      questions = questions_repondues.index_by(&:id)
      reponses.map { |reponse| [questions[reponse.donnees['question']], reponse] }
              .select { |q, _r| type_qcm.nil? || q.type_qcm == type_qcm.to_s }
              .map { |q, r| [q, choix_repondu(q, r)] }
    end

    def questions_redaction
      @questions_redaction ||= questions_et_reponses.select do |q, r|
        [q, r] if q.nom_technique == QuestionSaisie::QUESTION_REDACTION
      end
    end

    def reponses
      @reponses ||= @evenements.find_all { |e| e.nom == MetriquesHelper::EVENEMENT[:REPONSE] }
    end

    def choix_repondu(question, evenement_reponse)
      reponse = evenement_reponse.donnees['reponse']
      question.is_a?(QuestionQcm) ? question.choix.find { |c| c.id == reponse } : reponse
    end

    private

    def questions_repondues
      questions_ids = reponses.collect { |r| r.donnees['question'] }
      Question.where(id: questions_ids, type: 'QuestionQcm').includes(:choix) +
        Question.where(id: questions_ids).where.not(type: 'QuestionQcm')
    end
  end
end
