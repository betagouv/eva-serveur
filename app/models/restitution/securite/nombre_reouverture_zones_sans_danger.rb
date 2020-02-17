# frozen_string_literal: true

module Restitution
  class Securite
    class NombreReouvertureZonesSansDanger
      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        @evenements_situation.select(&:ouverture_zone_sans_danger?)
                             .group_by { |e| e.donnees['zone'] }
                             .inject(0) do |memo, (_danger, ouvertures)|
                               memo + ouvertures.count - 1
                             end
      end
    end
  end
end
