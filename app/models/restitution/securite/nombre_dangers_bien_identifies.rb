# frozen_string_literal: true

module Restitution
  class Securite
    class NombreDangersBienIdentifies
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        @evenements_situation.select(&:est_un_danger_bien_identifie?).count
      end
    end
  end
end
