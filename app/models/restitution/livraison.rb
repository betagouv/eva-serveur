# frozen_string_literal: true

require_relative '../../decorators/evenement_livraison'

module Restitution
  class Livraison < AvecEntrainement
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
      qr = QuestionsReponses.new(evenements_situation, situation.questionnaire)
      qr.questions_et_reponses
    end

    def efficience
      nil
    end
  end
end
