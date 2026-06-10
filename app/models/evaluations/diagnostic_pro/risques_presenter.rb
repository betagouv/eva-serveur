# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class RisquesPresenter
      SEUILS_PALIERS_RISQUE = {
        10 => "A",
        25 => "B",
        50 => "C",
        100 => "D"
      }.freeze

      def initialize(pourcentage_risque:)
        @pourcentage_risque = pourcentage_risque
      end

      attr_reader :pourcentage_risque

      def palier
        return if pourcentage_risque.nil?

        seuil_max = SEUILS_PALIERS_RISQUE.keys.find { |seuil| pourcentage_risque <= seuil }

        SEUILS_PALIERS_RISQUE[seuil_max]
      end
    end
  end
end
