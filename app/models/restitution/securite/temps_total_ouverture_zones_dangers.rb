# frozen_string_literal: true

module Restitution
  class Securite
    class TempsTotalOuvertureZonesDangers < Restitution::Metriques::Base
      def calcule
        temps_par_danger = {}
        evenements_par_danger.each do |danger, les_evenements|
          temps = MetriquesHelper.temps_entre_couples les_evenements
          temps_par_danger[danger] = temps.sum unless temps.empty?
        end
        temps_par_danger
      end

      private

      def evenements_par_danger
        SecuriteHelper.filtre_par_danger(@evenements_situation) do |e|
          e.ouverture_zone_danger? || e.qualification_danger?
        end
      end
    end
  end
end
