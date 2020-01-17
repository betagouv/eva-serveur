# frozen_string_literal: true

module Restitution
  class Securite
    class TempsBonnesQualificationsDangers
      def calcule(evenements_situation)
        resultat = []
        Metriques::ZONES_DANGER_SECURITE.each do |danger|
          evenements = evenements_situation.select do |e|
            filtre_evenement = e.ouverture_zone_danger? || e.bonne_qualification_danger?
            e.donnees['danger'] == danger && filtre_evenement
          end
          temps = MetriquesHelper.temps_entre_couples evenements
          resultat << temps.last
        end
        resultat
      end
    end
  end
end
