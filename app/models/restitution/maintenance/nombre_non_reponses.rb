# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreNonReponses
      attr_reader :evenements_situation

      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select(&:non_reponse?).count
      end
    end
  end
end
