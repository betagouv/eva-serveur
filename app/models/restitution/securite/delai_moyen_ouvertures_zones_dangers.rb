# frozen_string_literal: true

module Restitution
  class Securite
    class DelaiMoyenOuverturesZonesDangers
      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        delais = Metriques::SECURITE['delai_ouvertures_zones_dangers']
                 .new(@evenements_situation)
                 .calcule

        return nil if delais.empty?

        delais.sum.fdiv(delais.size)
      end
    end
  end
end
