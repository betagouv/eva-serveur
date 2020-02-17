# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreErreurs
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select(&:mauvaise_identification).count
      end
    end
  end
end
