# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class RisquesPresenter
      SEUILS_PALIERS_RISQUE = {
        10 => "A - Très bon",
        25 => "B - Bon",
        50 => "C - Moyen",
        100 => "D - Mauvais"
      }.freeze

      PALIER_TO_LETTRE = {
        "A - Très bon" => "a",
        "B - Bon" => "b",
        "C - Moyen" => "c",
        "D - Mauvais" => "d"
      }.freeze

      def initialize(pourcentage_risque:)
        @pourcentage_risque = pourcentage_risque
      end

      attr_reader :pourcentage_risque

      def palier
        return if pourcentage_risque.nil?

        seuil_max = SEUILS_PALIERS_RISQUE.keys.find { |seuil| pourcentage_risque <= seuil }
        return "D - Mauvais" if seuil_max.nil?

        SEUILS_PALIERS_RISQUE[seuil_max]
      end

      def lettre
        PALIER_TO_LETTRE.fetch(palier, "d")
      end
    end
  end
end
