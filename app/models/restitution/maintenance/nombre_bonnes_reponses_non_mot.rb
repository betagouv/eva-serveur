# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreBonnesReponsesNonMot
      attr_reader :evenements_situation

      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select(&:identification_non_mot_correct?).count
      end
    end
  end
end
