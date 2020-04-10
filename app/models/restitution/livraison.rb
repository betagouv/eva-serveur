# frozen_string_literal: true

module Restitution
  class Livraison < AvecEntrainement
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    METRIQUES = {
      'nombre_bonnes_reponses' => {
        'type' => :nombre
      }
    }.freeze

    def termine?
      super || reponses.size == questions.size
    end

    def questions_et_reponses
      questions_qcm_repondues
        .map do |question|
        {
          question: question,
          reponse: trouve_reponse(question.id)
        }
      end
    end

    def reponses
      evenements_situation.find_all { |e| e.nom == EVENEMENT[:REPONSE] }
    end

    def efficience
      nil
    end

    def nombre_bonnes_reponses
      questions_et_reponses.select do |question_et_reponse|
        choix = question_et_reponse[:question].choix.find(question_et_reponse[:reponse])
        choix.bon?
      end.count
    end

    private

    def questions
      situation.questionnaire.questions
    end

    def questions_qcm_repondues
      questions_ids = reponses.collect { |r| r.donnees['question'] }
      questions.where(id: questions_ids, type: 'QuestionQcm')
    end

    def trouve_reponse(question_id)
      reponses.find do |evenement|
        evenement.donnees['question'] == question_id
      end.donnees['reponse']
    end
  end
end
