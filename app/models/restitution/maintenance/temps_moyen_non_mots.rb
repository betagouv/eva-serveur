# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenNonMots
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        return 0 if nombre_identifications_non_mot_correct.zero?

        temps = Restitution::MetriquesHelper.temps_entre_couples(
          apparitions_et_identifications_non_mot_correctes
        )
        (temps.sum / nombre_identifications_non_mot_correct).round(4)
      end

      private

      def apparitions_et_identifications_non_mot_correctes
        evenements_retenus = []
        apparitions_et_identifications_non_mot.each_slice(2) do |apparition, identification|
          next unless identification.type_non_mot_correct

          evenements_retenus << apparition << identification
        end
        evenements_retenus
      end

      def apparitions_et_identifications_non_mot
        evenements_situation.select(&:apparition_ou_identification_non_mot)
      end

      def nombre_identifications_non_mot_correct
        evenements_situation.select(&:identification_non_mot_correcte).count
      end
    end
  end
end
