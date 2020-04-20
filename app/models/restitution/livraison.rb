# frozen_string_literal: true

require_relative '../../decorators/evenement_livraison'

module Restitution
  class Livraison < AvecEntrainement
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    METRIQUES = {
      'nombre_bonnes_reponses_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie',
        'instance' => Illettrisme::NombreBonnesReponses.new
      },
      'nombre_bonnes_reponses_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf',
        'instance' => Illettrisme::NombreBonnesReponses.new
      },
      'nombre_bonnes_reponses_syntaxe_orthographe' => {
        'type' => :nombre,
        'metacompetence' => 'syntaxe-orthographe',
        'instance' => Illettrisme::NombreBonnesReponses.new
      },
      'temps_moyen_bonnes_reponses_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie',
        'instance' => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      'temps_moyen_bonnes_reponses_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf',
        'instance' => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      'temps_moyen_bonnes_reponses_syntaxe_orthographe' => {
        'type' => :nombre,
        'metacompetence' => 'syntaxe-orthographe',
        'instance' => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementLivraison.new e }
      super(campagne, evenements)
    end

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements_situation, METRIQUES[metrique]['metacompetence'])
      end
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

    def persiste
      metriques = METRIQUES.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
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
