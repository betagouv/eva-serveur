# frozen_string_literal: true

module Restitution
  class Securite
    class DelaiOuverturesZonesDangers
      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_selectionnes = @evenements_situation.select do |e|
          e.demarrage? || e.qualification_danger? || e.ouverture_zone_danger?
        end
        MetriquesHelper.temps_entre_couples evenements_selectionnes
      end
    end
  end
end
