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
      'nombre_bonnes_reponses_memorisation' => {
        'type' => :nombre,
        'metacompetence' => 'memorisation',
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
      'temps_moyen_bonnes_reponses_memorisation' => {
        'type' => :nombre,
        'metacompetence' => 'memorisation',
        'instance' => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      'score_numeratie' => {
        'type' => :nombre,
        'metacompetence' => 'numeratie',
        'instance' => Illettrisme::ScoreMetacompetence.new
      },
      'score_ccf' => {
        'type' => :nombre,
        'metacompetence' => 'ccf',
        'instance' => Illettrisme::ScoreMetacompetence.new
      },
      'score_memorisation' => {
        'type' => :nombre,
        'metacompetence' => 'memorisation',
        'instance' => Illettrisme::ScoreMetacompetence.new
      }

    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementObjetsTrouves.new e }
      super
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements_situation, METRIQUES[metrique]['metacompetence'])
      end
    end
  end
end
