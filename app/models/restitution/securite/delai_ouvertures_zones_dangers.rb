module Restitution
  class Securite
    class DelaiOuverturesZonesDangers
      def calcule(evenements_situation, _)
        evenements_selectionnes = evenements_situation.select do |e|
          e.demarrage? || e.qualification_danger? || e.ouverture_zone_danger?
        end
        MetriquesHelper.temps_entre_couples evenements_selectionnes
      end
    end
  end
end
