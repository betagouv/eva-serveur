# frozen_string_literal: true

module Restitution
  class Metriques
    SECURITE = {
      'temps_total' => Securite,
      'temps_entrainement' => Securite,
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

    MAINTENANCE = {
      'nombre_bonnes_reponses_francais' => Maintenance::NombreBonnesReponsesMotFrancais,
      'nombre_bonnes_reponses_non_mot' => Maintenance::NombreBonnesReponsesNonMot,
      'nombre_non_reponses' => Maintenance::NombreNonReponses,
      'temps_moyen_mots_français' => Maintenance::TempsMoyenMotsFrancais,
      'temps_moyen_non_mots' => Maintenance::TempsMoyenNonMots
    }.freeze
  end
end
