module Admin
  module BeneficiaireHelper
    def statut_suivi_beneficiaire(beneficiaire, beneficiaires)
      @statuts_suivi_beneficiaires ||=
        Beneficiaires::StatutSuivi.par_beneficiaire(beneficiaires.map(&:id))
      render StatutSuiviComponent.new(statut: @statuts_suivi_beneficiaires[beneficiaire.id])
    end

    def actions_beneficiaire
      [
        { label: t("admin.beneficiaires.index.voir"), type: :read, url: :admin_beneficiaire_path },
        { label: t("admin.beneficiaires.index.modifier"), type: :edit,
          url: :edit_admin_beneficiaire_path },
        { label: t("admin.beneficiaires.index.supprimer"), type: :destroy,
          url: :admin_beneficiaire_path, method: :delete,
          data: { confirm: t("admin.beneficiaires.index.confirmation_suppression") } }
      ]
    end
  end
end
