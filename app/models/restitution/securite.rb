# frozen_string_literal: true

module Restitution
  class Securite < AvecEntrainement
    ZONES_DANGER = %w[bouche-egout camion casque escabeau signalisation].freeze
    METRIQUES = {
      'temps_total' => 'parent',
      'temps_entrainement' => 'parent',
      'nombre_rejoue_consigne' => 'parent',
      'nombre_dangers_bien_identifies' => Securite::NombreDangersBienIdentifies,
      'nombre_dangers_bien_identifies_avant_aide_1' =>
                                          Securite::NombreDangersBienIdentifiesAvantAide1,
      'nombre_dangers_mal_identifies' => Securite::NombreDangersMalIdentifies,
      'attention_visuo_spatiale' => Securite::AttentionVisuoSpaciale,
      'temps_bonnes_qualifications_dangers' => Securite::TempsBonnesQualificationsDangers,
      'temps_recherche_zones_dangers' => Securite::TempsRechercheZonesDangers,
      'temps_total_ouverture_zones_dangers' => Securite::TempsTotalOuvertureZonesDangers,
      'nombre_reouverture_zones_sans_danger' => Securite::NombreReouvertureZonesSansDanger,
      'nombre_bien_qualifies' => Securite::NombreDangersBienQualifies,
      'nombre_retours_deja_qualifies' => Securite::NombreRetoursDejaQualifies,
      'delai_ouvertures_zones_dangers' => Securite::DelaiOuverturesZonesDangers,
      'delai_moyen_ouvertures_zones_dangers' => Securite::DelaiMoyenOuverturesZonesDangers
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementSecuriteDecorator.new e }
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
        clazz = METRIQUES[metrique]
        if clazz == 'parent'
          super()
        else
          clazz
            .new(evenements_situation)
            .calcule
        end
      end
    end
  end
end
