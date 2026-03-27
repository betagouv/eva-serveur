# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class ImpactsPresenter
      INTERPRETATIONS = %i[
        performance_collective
        agilite_organisationnelle
        securite_qualite
        mobilite_professionnelle
      ].freeze

      def initialize(evaluation_impact_general:, evaluation_id:)
        @evaluation_impact_general = evaluation_impact_general
        @evaluation_id = evaluation_id
      end

      def complet?
        @evaluation_impact_general.present?
      end

      def synthese
        return unless complet?

        @evaluation_impact_general.synthese
      end

      def interpretations
        INTERPRETATIONS
      end

      def incomplet_url(base_url)
        "#{base_url}/evaluation-impact?evaluation_id=#{@evaluation_id}"
      end
    end
  end
end
