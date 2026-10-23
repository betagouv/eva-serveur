module Admin
  module EvaluationHelper
    def niveau_bas?(profil)
      ::Competence::PROFILS_BAS.include?(profil)
    end

    def affiche_colonne_structure?(compte = current_compte)
      compte.anlci? || compte.administratif?
    end

    def affiche_sous_titre_campagne?(parcours_type, compte = current_compte)
      parcours_type.present? && !compte.administratif?
    end

    def statut_suivi(evaluation, evaluations)
      @statuts_suivi ||= EvaluationsEva::StatutSuivi.par_evaluation(evaluations.map(&:id))
      render StatutSuiviComponent.new(statut: @statuts_suivi[evaluation.id])
    end

    def destroy
      destroy!(location: location_apres_suppression)
    end

    private

    def location_apres_suppression
      return request.referer if referer_conserve?

      collection_path
    end

    def referer_conserve?
      referer_path = URI(request.referer).path if request.referer
      referer_path == URI(collection_path).path ||
        referer_path == admin_beneficiaire_path(resource.beneficiaire)
    end
  end
end
