# frozen_string_literal: true

require_relative '../../decorators/evenement_securite'

module Restitution
  class Securite < AvecEntrainement
    ZONES_DANGER = %w[bouche-egout camion casque escabeau signalisation].freeze
    METRIQUES = {
      'temps_total' => {
        'type' => :temps,
        'instance' => Base::TempsTotal.new
      },
      'temps_entrainement' => {
        'type' => :temps,
        'instance' => AvecEntrainement::TempsEntrainement.new
      },
      'nombre_dangers_bien_identifies' => {
        'type' => :nombre,
        'instance' => Securite::NombreDangersBienIdentifies.new
      },
      'nombre_dangers_bien_identifies_avant_aide_1' => {
        'type' => :nombre,
        'instance' => Securite::NombreDangersBienIdentifiesAvantAide1.new
      },
      'nombre_dangers_mal_identifies' => {
        'type' => :nombre,
        'instance' => Securite::NombreDangersMalIdentifies.new
      },
      'attention_visuo_spatiale' => {
        'type' => :texte,
        'instance' => Securite::AttentionVisuoSpaciale.new
      },
      'temps_bonnes_qualifications_dangers' => {
        'type' => :map,
        'instance' => Securite::TempsBonnesQualificationsDangers.new
      },
      'temps_recherche_zones_dangers' => {
        'type' => :map,
        'instance' => Securite::TempsRechercheZonesDangers.new
      },
      'temps_total_ouverture_zones_dangers' => {
        'type' => :map,
        'instance' => Securite::TempsTotalOuvertureZonesDangers.new
      },
      'nombre_reouverture_zones_sans_danger' => {
        'type' => :nombre,
        'instance' => Securite::NombreReouvertureZonesSansDanger.new
      },
      'nombre_bien_qualifies' => {
        'type' => :nombre,
        'instance' => Securite::NombreDangersBienQualifies.new
      },
      'nombre_retours_deja_qualifies' => {
        'type' => :nombre,
        'instance' => Securite::NombreRetoursDejaQualifies.new
      },
      'delai_ouvertures_zones_dangers' => {
        'type' => :liste_temps,
        'instance' => Securite::DelaiOuverturesZonesDangers.new
      },
      'delai_moyen_ouvertures_zones_dangers' => {
        'type' => :temps,
        'instance' => Metriques::Moyenne.new(Securite::DelaiOuverturesZonesDangers.new)
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementSecurite.new e }
      super(campagne, evenements)
    end

    def termine?
      super ||
        SecuriteHelper.qualifications_par_danger(evenements_situation).count == ZONES_DANGER.count
    end

    def persiste
      metriques = METRIQUES.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements_situation, evenements_entrainement)
      end
    end
  end
end
