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

    def titre
      evaluation.structure&.nom
    end

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
