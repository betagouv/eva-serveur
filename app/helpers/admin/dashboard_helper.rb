module Admin
  module DashboardHelper
    include EvaluationHelper

    def eva_pro_locals(campagnes:, evaluations:, cinq_dernieres_evaluations_completes:,
actualites:, compte:, ability:)
      structure = compte.structure
      opco_financeur = structure&.opco_financeur
      premiere_reponse_complete =
        Evaluation.au_moins_une_reponse_pour_structure?(structure)
      derniere_evaluation_complete =
        derniere_evaluation_complete(structure, ability)

      restitution_globale = if derniere_evaluation_complete.present?
                              FabriqueRestitution.restitution_globale(derniere_evaluation_complete)
      end

      {
        campagnes: campagnes,
        evaluations: evaluations,
        cinq_dernieres_evaluations_completes: cinq_dernieres_evaluations_completes,
        actualites: actualites,
        opco: opco_financeur,
        structure: structure,
        premiere_reponse_complete: premiere_reponse_complete,
        derniere_evaluation_complete: derniere_evaluation_complete,
        restitution_globale: restitution_globale
      }
    end

    def eva_locals(evaluations:, actualites:, campagnes:)
      {
        evaluations: evaluations,
        actualites: actualites,
        campagnes: campagnes
      }
    end

    private

    def derniere_evaluation_complete(structure, ability)
      parcours_type_ids =
        ParcoursType.where(type_de_programme: "diagnostic_entreprise").select(:id)

      Evaluation.accessible_by(ability)
                .pour_structure(structure)
                .avec_reponse
                .where(campagnes: { parcours_type_id: parcours_type_ids })
                .order(created_at: :desc)
                .first
    end

    def restitution_globale_pour(evaluation)
      @restitution_globale_pour ||= {}
      @restitution_globale_pour[evaluation.id] ||=
        FabriqueRestitution.restitution_globale(evaluation)
    end

    def lettre_risque_pour(evaluation)
      pourcentage_risque =
        restitution_globale_pour(evaluation)
          .diag_risques_entreprise
          &.synthese
          &.dig(:pourcentage_risque)
      return if pourcentage_risque.blank?

      palier = palier_pourcentage_risque(pourcentage_risque)
      palier_to_lettre(palier).upcase
    end

    def lettre_couts_pour(evaluation)
      score_cout =
        restitution_globale_pour(evaluation)
          .evaluation_impact_general
          &.synthese
          &.dig(:score_cout)
      return if score_cout.blank?

      palier = palier_score_cout(score_cout)
      palier_to_lettre(palier).upcase
    end
  end
end
