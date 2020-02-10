# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenNonMots
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        return 0 if nombre_identification_non_mot_correcte.zero?

        temps = Restitution::MetriquesHelper.temps_entre_couples(recupere_couples)
        (temps.sum / nombre_identification_non_mot_correcte).round(4)
      end

      private

      def recupere_couples
        couples_correctes = []
        apparition_identification_non_mot.each_slice(2) do |a|
          couples_correctes << a if a.last.type_non_mot_correct
        end
        couples_correctes.flatten
      end

      def apparition_identification_non_mot
        evenements_situation.select(&:apparition_ou_identification_non_mot)
      end

      def nombre_identification_non_mot_correcte
        recupere_couples.count / 2
      end
    end
  end
end
