# frozen_string_literal: true

module Restitution
  class Questions < Base
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    def termine?
      reponses.size == questions.size
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

    def nombre_questions_qcm
      questions.select { |q| q.is_a?(QuestionQcm) }.count
    end

    def choix_repondu(question)
      question_et_reponse = questions_et_reponses.find do |question_reponse|
        question_reponse[:question].id == question.id
      end
      return unless question_et_reponse

      question_et_reponse[:question].choix.find(question_et_reponse[:reponse])
    end

    def efficience
      question_qcm_repondue = questions_et_reponses.select { |q| q[:question].is_a?(QuestionQcm) }
      points_total = points_par_question(question_qcm_repondue).inject(0, :+)
      (points_total / nombre_questions_qcm.to_f) * 100.0
    end

    def points_par_question(questions)
      questions.map! do |a|
        case a[:question].choix.find(a[:reponse]).type_choix
        when 'bon'
          1
        when 'abstention'
          0.25
        else
          0
        end
      end
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
