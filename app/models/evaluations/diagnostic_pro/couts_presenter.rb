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

      SCORE_TO_LETTRE = {
        "faible" => "a",
        "moyen" => "b",
        "fort" => "c",
        "tres_fort" => "d"
      }.freeze

      def initialize(synthese:, i18n:)
        @synthese = (synthese || {}).transform_keys(&:to_sym)
        @i18n = i18n
      end

      def score_to_lettre(score)
        SCORE_TO_LETTRE.fetch(score.to_s, score.to_s)
      end

      def palier_score_cout(score_cout)
        SCORE_COUT_TO_PALIER.fetch(score_cout.to_s.to_sym, "D - Mauvais")
      end

      def contenu_cout
        lettre = score_to_lettre(@synthese[:score_cout])
        {
          titre: @i18n.t(
            "admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.titre.#{lettre}"
          ),
          texte: @i18n.t("admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.texte"),
          suite: @i18n.t(
            "admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.suite.#{lettre}"
          )
        }
      end

      def explication_strategie
        lettre = score_to_lettre(@synthese[:score_strategie])
        base_path = "admin.evaluations.mesure_des_impacts.impact_couts.explications_strategies"
        {
          titre: @i18n.t("#{base_path}.titre.#{lettre}"),
          texte: @i18n.t("#{base_path}.texte.#{lettre}")
        }
      end

      def explication_numerique
        lettre = score_to_lettre(@synthese[:score_numerique])
        base_path = "admin.evaluations.mesure_des_impacts.impact_couts.explications_numerique"
        {
          titre: @i18n.t("#{base_path}.titre.#{lettre}"),
          texte: @i18n.t("#{base_path}.texte.#{lettre}")
        }
      end

      def lettre_score_strategie
        score_to_lettre(@synthese[:score_strategie])
      end

      def lettre_score_numerique
        score_to_lettre(@synthese[:score_numerique])
      end
    end
  end
end
