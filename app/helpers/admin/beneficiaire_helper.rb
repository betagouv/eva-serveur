module Admin
  module BeneficiaireHelper
    def statut_suivi_beneficiaire(beneficiaire, beneficiaires)
      @statuts_suivi_beneficiaires ||=
        Beneficiaires::StatutSuivi.par_beneficiaire(beneficiaires.map(&:id))
      render StatutSuiviComponent.new(statut: @statuts_suivi_beneficiaires[beneficiaire.id])
    end
  end
end
