module Admin
  module DashboardHelper
    def eva_pro_locals(campagnes:, evaluations:, cinq_dernieres_evaluations_completes:,
actualites:, compte:, ability:)
      structure = compte.structure
      opco_financeur = structure&.opco_financeur
      premiere_reponse_complete =
        Evaluation.au_moins_une_reponse_pour_structure?(structure)
      derniere_eval = derniere_evaluation_complete(structure, ability)

      restitution_globale = if derniere_eval.present?
                              FabriqueRestitution.restitution_globale(derniere_eval)
      end

      {
        campagnes: campagnes,
        evaluations: evaluations,
        cinq_dernieres_evaluations_completes: cinq_dernieres_evaluations_completes,
        actualites: actualites,
        opco: opco_financeur,
        structure: structure,
        premiere_reponse_complete: premiere_reponse_complete,
        derniere_evaluation_complete: derniere_eval,
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

    def lettre_risque_pour(evaluation, synthese_evapro = nil)
      pourcentage_risque =
        if synthese_evapro.present?
          synthese_evapro[:pourcentage_risque]
        else
          pourcentage_risque_via_diagnostic_pro(evaluation)
        end
      return if pourcentage_risque.blank?

      palier = Evaluations::DiagnosticPro::RisquesPresenter.new(
        pourcentage_risque: pourcentage_risque.to_i
      ).palier

      Evaluations::DiagnosticPro::RisquesPresenter::PALIER_TO_LETTRE.fetch(palier, "d").upcase
    end

    def lettre_couts_pour(evaluation, synthese_evapro = nil)
      score_cout =
        if synthese_evapro.present?
          synthese_evapro[:score_cout]
        else
          score_cout_via_diagnostic_pro(evaluation)
        end
      return if score_cout.blank?

      palier = Evaluations::DiagnosticPro::CoutsPresenter.new(
        synthese: { score_cout: score_cout },
        i18n: I18n
      ).palier_score_cout(score_cout)

      Evaluations::DiagnosticPro::RisquesPresenter::PALIER_TO_LETTRE.fetch(palier, "d").upcase
    end

    def afficher_lettre_cout(evaluation, synthese_evapro = nil)
      synthese_evapro ||= synthese_evapro_pour(evaluation)
      lettre_couts = lettre_couts_pour(evaluation, synthese_evapro)
      if lettre_couts.present? && evaluation.complete?
        render EvaProScoreComponent.new(active_letter: lettre_couts)
      else
        "-"
      end
    end

    def afficher_lettre_risque(evaluation, synthese_evapro = nil)
      synthese_evapro ||= synthese_evapro_pour(evaluation)
      lettre_risque = lettre_risque_pour(evaluation, synthese_evapro)
      if lettre_risque.present? && evaluation.complete?
        render EvaProScoreComponent.new(active_letter: lettre_risque)
      else
        "-"
      end
    end

    def afficher_lettre_risque_index_evapro(evaluation, synthese_evapro)
      lettre_risque = Admin::DashboardHelper.instance_method(:lettre_risque_pour).bind(self).call(
evaluation, synthese_evapro)
      if lettre_risque.present? && evaluation.complete?
        render EvaProScoreComponent.new(active_letter: lettre_risque)
      else
        "-"
      end
    end

    def afficher_lettre_cout_index_evapro(evaluation, synthese_evapro)
      lettre_couts = Admin::DashboardHelper.instance_method(:lettre_couts_pour).bind(self).call(
evaluation, synthese_evapro)
      if lettre_couts.present? && evaluation.complete?
        render EvaProScoreComponent.new(active_letter: lettre_couts)
      else
        "-"
      end
    end

    private

    def synthese_evapro_pour(evaluation)
      return nil unless respond_to?(:syntheses_evapro_par_evaluation_id, true)

      syntheses_evapro_par_evaluation_id&.[](evaluation.id)
    end

    def derniere_evaluation_complete(structure, ability)
      parcours_type_ids =
        ParcoursType.where(type_de_programme: "diagnostic_entreprise").select(:id)

      Evaluation.accessible_by(ability)
                .pour_structure(structure)
                .avec_reponse
                .where(campagnes: { parcours_type_id: parcours_type_ids })
                .where(completude: :complete)
                .order(created_at: :desc)
                .first
    end

    def restitution_globale_pour(evaluation)
      @restitution_globale_pour ||= {}
      @restitution_globale_pour[evaluation.id] ||=
        FabriqueRestitution.restitution_globale(evaluation)
    end

    def pourcentage_risque_via_diagnostic_pro(evaluation)
      rg = restitution_globale_pour(evaluation)
      rest_pro = evaluation.diagnostic_pro&.avec_restitution_globale(rg)
      rest_pro&.pourcentage_risque
    end

    def score_cout_via_diagnostic_pro(evaluation)
      rg = restitution_globale_pour(evaluation)
      rest_pro = evaluation.diagnostic_pro&.avec_restitution_globale(rg)
      rest_pro&.synthese_impact_general&.dig(:score_cout)
    end
  end
end
