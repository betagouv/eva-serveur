require_relative "../../decorators/evenement_securite"

module Restitution
  class Securite < AvecEntrainement
    ZONES_DANGER = %w[bouche-egout camion casque escabeau signalisation].freeze
    METRIQUES = {
      "temps_total" => {
        "type" => :nombre,
        "instance" => Restitution::Base::TempsTotal.new
      },
      "temps_entrainement" => {
        "type" => :nombre,
        "instance" => Restitution::AvecEntrainement::TempsEntrainement.new
      },
      "nombre_dangers_bien_identifies" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreDangersBienIdentifies.new
      },
      "nombre_dangers_bien_identifies_avant_aide1" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreDangersBienIdentifiesAvantAide1.new
      },
      "nombre_dangers_mal_identifies" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreDangersMalIdentifies.new
      },
      "attention_visuo_spatiale" => {
        "type" => :texte,
        "instance" => Restitution::Securite::AttentionVisuoSpaciale.new
      },
      "temps_bonnes_qualifications_dangers" => {
        "type" => :map,
        "instance" => Restitution::Securite::TempsBonnesQualificationsDangers.new
      },
      "temps_recherche_zones_dangers" => {
        "type" => :map,
        "instance" => Restitution::Securite::TempsRechercheZonesDangers.new
      },
      "temps_moyen_recherche_zones_dangers" => {
        "type" => :nombre,
        "instance" => Restitution::Metriques::Moyenne.new(
          Restitution::Metriques::MapToList.new(
            Restitution::Securite::TempsRechercheZonesDangers.new
          )
        )
      },
      "temps_total_ouverture_zones_dangers" => {
        "type" => :map,
        "instance" => Restitution::Securite::TempsTotalOuvertureZonesDangers.new
      },
      "nombre_reouverture_zones_sans_danger" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreReouvertureZonesSansDanger.new
      },
      "nombre_bien_qualifies" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreDangersBienQualifies.new
      },
      "nombre_retours_deja_qualifies" => {
        "type" => :nombre,
        "instance" => Restitution::Securite::NombreRetoursDejaQualifies.new
      },
      "delai_ouvertures_zones_dangers" => {
        "type" => :liste,
        "instance" => Restitution::Securite::DelaiOuverturesZonesDangers.new
      },
      "delai_moyen_ouvertures_zones_dangers" => {
        "type" => :nombre,
        "instance" => Restitution::Metriques::Moyenne.new(
          Restitution::Securite::DelaiOuverturesZonesDangers.new
        )
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementSecurite.new e }
      super
    end

    def termine?
      super ||
        Restitution::Securite::SecuriteHelper
          .qualifications_par_danger(evenements_situation).count == ZONES_DANGER.count
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]["instance"]
          .calcule(evenements_situation, evenements_entrainement)
      end
    end

    def competences
      calcule_competences(
        ::Competence::ATTENTION_CONCENTRATION => Securite::AttentionConcentration
      )
    end
  end
end
