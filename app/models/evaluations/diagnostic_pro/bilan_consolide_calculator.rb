# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class BilanConsolideCalculator
      PALIER_PAR_SCORE = {
        (0..41) => "A",
        (42..83) => "B",
        (84..126) => "C",
        (127..167) => "D"
      }.freeze

      MALUS_PAR_POURCENTAGE_RISQUE = {
        (0..10) => 0,
        (11..25) => 1,
        (26..50) => 2,
        (51..75) => 3
      }.freeze

      def initialize(diag_risques_entreprise:, evaluation_impact_general:)
        @diag_risques_entreprise = diag_risques_entreprise
        @evaluation_impact_general = evaluation_impact_general
      end

      def palier
        _interval, niveau = PALIER_PAR_SCORE.find { |interval, _| interval.cover?(score_total) }
        niveau || "D"
      end

      def score_total
        score_risque + score_cout_final + score_strategie_final + score_numerique_final
      end

      private

      attr_reader :diag_risques_entreprise, :evaluation_impact_general

      def score_risque
        evenements_reponses_risques.sum { |evenement| evenement.donnees["score"] || 0 }
      end

      def score_cout_final
        score_impact("score_cout") + malus
      end

      def score_strategie_final
        score_impact("score_strategies") + malus
      end

      def score_numerique_final
        score_impact("score_numerique") + malus
      end

      def score_impact(cle)
        evenements_reponses_impacts.sum { |evenement| evenement.donnees[cle] || 0 }
      end

      def malus
        pourcentage = pourcentage_risque
        return 0 if pourcentage.nil?

        MALUS_PAR_POURCENTAGE_RISQUE.each do |interval, valeur|
          return valeur if interval.cover?(pourcentage)
        end

        0
      end

      def pourcentage_risque
        synthese = diag_risques_entreprise&.partie&.synthese
        return if synthese.blank?

        synthese["pourcentage_risque"] || synthese[:pourcentage_risque]
      end

      def evenements_reponses_risques
        ::Restitution::MetriquesHelper.filtre_evenements_reponses(evenements_risques)
      end

      def evenements_reponses_impacts
        ::Restitution::MetriquesHelper.filtre_evenements_reponses(evenements_impacts)
      end

      def evenements_risques
        diag_risques_entreprise&.partie&.evenements || []
      end

      def evenements_impacts
        evaluation_impact_general&.partie&.evenements || []
      end
    end
  end
end
