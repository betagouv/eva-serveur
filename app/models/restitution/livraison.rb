# frozen_string_literal: true

module Restitution
  class Livraison < AvecEntrainement
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    METRIQUES = {
      'nombre_bonnes_reponses_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie'
      },
      'nombre_bonnes_reponses_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf'
      },
      'nombre_bonnes_reponses_syntaxe_orthographe' => {
        'type' => :nombre,
        'metacompetence' => 'syntaxe-orthographe'
      }
    }.freeze

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        nombre_bonnes_reponses METRIQUES[metrique]['metacompetence']
      end
    end

    def termine?
      super || reponses.size == questions.size
    end

    def questions_et_reponses
      questions_qcm_repondues
        .map do |question|
        {
          question: question,
          reponse: trouve_reponse(question)
        }
      end
    end

    def reponses
      evenements_situation.find_all { |e| e.nom == EVENEMENT[:REPONSE] }
    end

    def efficience
      nil
    end

    def nombre_bonnes_reponses(metacompetence)
      questions_et_reponses.select do |q_r|
        q_r[:question].metacompetence == metacompetence &&
          q_r[:reponse].bon?
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

    def trouve_reponse(question)
      reponse_id = reponses.find do |evenement|
        evenement.donnees['question'] == question.id
      end.donnees['reponse']
      question.choix.find reponse_id
    end
  end
end
