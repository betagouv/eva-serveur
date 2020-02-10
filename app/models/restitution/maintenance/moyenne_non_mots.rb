# frozen_string_literal: true

module Restitution
  class Maintenance
    class MoyenneNonMots
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        return 0 if evenements_identifications.zero?

        (recupere_non_mot_correct.to_f / evenements_identifications)
      end

      private

      def recupere_non_mot_correct
        evenements_situation.select(&:type_non_mot_correct)
                            .count
      end

      def evenements_identifications
        evenements_situation.select(&:type_non_mot)
                            .count
      end
    end
  end
end
