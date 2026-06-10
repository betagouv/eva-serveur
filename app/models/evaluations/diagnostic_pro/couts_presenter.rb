# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    class CoutsPresenter
      def initialize(synthese:, i18n:)
        @synthese = (synthese || {}).transform_keys(&:to_sym)
        @i18n = i18n
      end

      def contenu_cout
        return nil if @synthese[:score_cout].blank?

        score = @synthese[:score_cout]
        {
          titre: @i18n.t(
            "admin.evaluations.evapro.impact_couts.contenu_cout.titre.#{score}"
          ),
          texte: @i18n.t("admin.evaluations.evapro.impact_couts.contenu_cout.texte.#{score}"),
          suite: @i18n.t(
            "admin.evaluations.evapro.impact_couts.contenu_cout.suite.#{score}"
          )
        }
      end

      def lettre(score_indicateur)
        SCORE_TO_LETTRE.fetch(@synthese[score_indicateur].to_s)
      end
    end
  end
end
