# frozen_string_literal: true

module Restitution
  class Securite
    class NombreDangersBienIdentifies
      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        @evenements_situation.select(&:est_un_danger_bien_identifie?).count
      end
    end
  end
end
