# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    attr_reader :evaluation

    def initialize(evaluation)
      @evaluation = evaluation
    end

    def evapro?
      true
    end

    def opco_financeur
      structure = evaluation.campagne&.compte&.structure
      return if structure.blank?

      structure.opco_financeur
    end

    def opco
      structure = evaluation.campagne&.compte&.structure
      return if structure.blank?

      structure.opco
    end

    def with_restitution_globale(restitution_globale)
      Restitution.new(restitution_globale: restitution_globale)
    end

    class Restitution
      def initialize(restitution_globale:)
        @restitution_globale = restitution_globale
      end

      def diag_risques_entreprise
        @restitution_globale.diag_risques_entreprise
      end

      def pourcentage_risque
        diag = diag_risques_entreprise
        return if diag.blank?

        diag.partie.synthese["pourcentage_risque"]
      end

      def evaluation_impact_general
        @restitution_globale.evaluation_impact_general
      end

      def complet?
        evaluation_impact_general.present?
      end

      def synthese_impact_general
        return unless complet?

        evaluation_impact_general.synthese
      end

      def affiche_bilan?
        diag_risques_entreprise.present? && evaluation_impact_general.present?
      end
    end
  end
end

