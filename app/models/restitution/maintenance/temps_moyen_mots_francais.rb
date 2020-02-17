# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenMotsFrancais
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        temps = Restitution::MetriquesHelper.temps_entre_couples(
          apparitions_et_identifications_mot_francais_correctes
        )
        return nil if temps.count.zero?

        (temps.sum / temps.count).round(4)
      end

      private

      def apparitions_et_identifications_mot_francais_correctes
        evenements_retenus = []
        apparitions_et_identifications_mot_francais.each_slice(2) do |apparition, identification|
          next unless identification.identification_mot_francais_correct

          evenements_retenus << apparition << identification
        end
        evenements_retenus
      end

      def apparitions_et_identifications_mot_francais
        evenements_situation.select(&:type_mot_francais)
      end
    end
  end
end
