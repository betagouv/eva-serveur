# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class CoutsPresenter
      SCORE_COUT_TO_PALIER = {
        faible: "A - Très bon",
        moyen: "B - Bon",
        fort: "C - Moyen",
        tres_fort: "D - Mauvais"
      }.freeze

      def initialize(synthese:, i18n:)
        @synthese = (synthese || {}).transform_keys(&:to_sym)
        @i18n = i18n
      end

      def score_to_lettre(score)
        SCORE_TO_LETTRE.fetch(score.to_s)
      end

      def palier_score_cout
        SCORE_COUT_TO_PALIER.fetch(@synthese[:score_cout].to_s.to_sym)
      end

      def contenu_cout
        return nil if @synthese[:score_cout].blank?

        lettre = score_to_lettre(@synthese[:score_cout])
        {
          titre: @i18n.t(
            "admin.evaluations.evapro.impact_couts.contenu_cout.titre.#{lettre}"
          ),
          texte: @i18n.t("admin.evaluations.evapro.impact_couts.contenu_cout.texte.#{lettre}"),
          suite: @i18n.t(
            "admin.evaluations.evapro.impact_couts.contenu_cout.suite.#{lettre}"
          )
        }
      end

      def lettre(score_indicateur)
        score_to_lettre(@synthese[score_indicateur])
      end
    end
  end
end
