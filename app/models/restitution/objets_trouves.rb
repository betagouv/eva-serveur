# frozen_string_literal: true

require_relative '../../decorators/evenement_objets_trouves'

module Restitution
  class ObjetsTrouves < AvecEntrainement
    METRIQUES = {
      'nombre_reponses_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf',
        'instance' => Illettrisme::NombreReponses.new
      },
      'nombre_reponses_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie',
        'instance' => Illettrisme::NombreReponses.new
      },
      'nombre_reponses_memorisation' => {
        'type' => :nombre,
        'metacompetence' => 'memorisation',
        'instance' => Illettrisme::NombreReponses.new
      },
      'score_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie',
        'instance' => Metriques::Somme.new(
          Illettrisme::ScoreQuestion.new(Illettrisme::TempsReponses.new)
        )
      },
      'score_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf',
        'instance' => Metriques::Somme.new(
          Illettrisme::ScoreQuestion.new(Illettrisme::TempsReponses.new)
        )
      },
      'score_memorisation' => {
        'type' => :nombre,
        'metacompetence' => 'memorisation',
        'instance' => Metriques::Somme.new(
          Illettrisme::ScoreQuestion.new(Illettrisme::TempsReponses.new)
        )
      }

    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementObjetsTrouves.new e }
      super(campagne, evenements)
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements_situation, METRIQUES[metrique]['metacompetence'])
      end
    end
  end
end
