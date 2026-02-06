module Admin
  module DashboardHelper
    def eva_pro_locals(campagnes:, evaluations:, actualites:, compte:, ability:)
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
  end
end
