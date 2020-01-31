# frozen_string_literal: true

module Restitution
  class Metriques
    SECURITE = {
      'temps_bonnes_qualifications_dangers' => Securite::TempsBonnesQualificationsDangers,
      'temps_recherche_zones_dangers' => Securite::TempsRechercheZonesDangers,
      'temps_total_ouverture_zones_dangers' => Securite::TempsTotalOuvertureZonesDangers,
      'nombre_reouverture_zone_sans_danger' => Securite,
      'nombre_bien_qualifies' => Securite,
      'nombre_dangers_bien_identifies' => Securite,
      'nombre_retours_deja_qualifies' => Securite,
      'nombre_dangers_bien_identifies_avant_aide_1' => Securite,
      'attention_visuo_spatiale' => Securite,
      'delai_ouvertures_zones_dangers' => Securite,
      'delai_moyen_ouvertures_zones_dangers' => Securite,
      'temps_entrainement' => Securite,
      'temps_total' => Securite,
      'nombre_rejoue_consigne' => Securite,
      'nombre_danger_mal_identifies' => Securite
    }.freeze
  end
end
