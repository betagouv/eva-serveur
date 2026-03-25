# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class Restitution
      def initialize(restitution_globale:)
        @restitution_globale = restitution_globale
      end

      def diag_risques_entreprise
        @restitution_globale.diag_risques_entreprise
      end

      def palier_risque
        diag_risques_entreprise&.palier
      end

      def affiche_bilan_risque?
        palier_risque.present?
      end

      def pourcentage_risque
        diag = diag_risques_entreprise
        return if diag.blank?

        diag.partie.synthese["pourcentage_risque"]
      end

      def evaluation_impact_general
        @restitution_globale.evaluation_impact_general
      end

      def impacts_presenter(evaluation_id:)
        ImpactsPresenter.new(
          evaluation_impact_general: evaluation_impact_general,
          evaluation_id: evaluation_id
        )
      end

      def risques_presenter
        RisquesPresenter.new(pourcentage_risque: pourcentage_risque)
      end

      def couts_presenter(synthese:, i18n:)
        CoutsPresenter.new(synthese: synthese, i18n: i18n)
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
