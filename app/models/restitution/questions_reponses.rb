module Restitution
  class QuestionsReponses
    def initialize(evenements)
      @evenements = evenements
    end

    def questions_et_reponses(type_qcm = nil)
      questions_et_evenements_reponse
        .select { |q, _e| type_qcm.nil? || q.type_qcm == type_qcm.to_s }
        .map { |q, e| [ q, choix_repondu(q, e) ] }
    end

    def questions_redaction
      @questions_redaction ||= questions_et_evenements_reponse
        .select { |q, _e| q.nom_technique == QuestionSaisie::QUESTION_REDACTION }
        .map { |q, e| [ q, reponse_redaction(e) ] }
    end

    def reponses
      @reponses ||= @evenements.find_all { |e| e.nom == MetriquesHelper::EVENEMENT[:REPONSE] }
    end

    def choix_repondu(question, evenement_reponse)
      reponse = evenement_reponse.donnees["reponse"]
      question.is_a?(QuestionQcm) ? question.choix.find { |c| c.id == reponse } : reponse
    end

    private

    def questions_et_evenements_reponse
      questions = questions_repondues.index_by(&:id)
      reponses.map { |reponse| [ questions[reponse.donnees["question"]], reponse ] }
              .select { |q, _e| q.present? }
    end

    def reponse_redaction(evenement_reponse)
      return I18n.t("admin.restitutions.redaction_passee") if evenement_reponse.donnees["neSaisPas"]

      evenement_reponse.donnees["reponse"]
    end

    def questions_repondues
      questions_ids = reponses.collect { |r| r.donnees["question"] }
      Question.where(id: questions_ids, type: QuestionQcm::QUESTION_TYPE).includes(:choix) +
        Question.where(id: questions_ids).where.not(type: QuestionQcm::QUESTION_TYPE)
    end
  end
end
