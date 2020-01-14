# frozen_string_literal: true

module Restitution
  class Metriques
    def self.temps_entre_couples(evenements)
      les_temps = []
      evenements.each_slice(2) do |e1, e2|
        next if e2.blank?

        les_temps << e2.date - e1.date
      end
      les_temps
    end

    SECURITE = %i[
      nombre_reouverture_zone_sans_danger nombre_bien_qualifies
      nombre_dangers_bien_identifies nombre_retours_deja_qualifies
      nombre_dangers_bien_identifies_avant_aide_1 attention_visuo_spatiale
      temps_ouvertures_zones_dangers temps_moyen_ouvertures_zones_dangers
      temps_entrainement temps_total nombre_rejoue_consigne nombre_danger_mal_identifies
    ].freeze

    REGLES_SECURITE = {
      'temps_bonnes_qualifications_dangers' => Securite::TempsBonnesQualificationsDangers
    }.freeze
  end
end
