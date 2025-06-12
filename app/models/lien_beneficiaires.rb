class LienBeneficiaires
  attr_reader :beneficiaire, :beneficiaires_a_fusionner

  def initialize(beneficiaire, beneficiaires_a_fusionner)
    @beneficiaire = beneficiaire
    @beneficiaires_a_fusionner = beneficiaires_a_fusionner
  end

  def call
    Evaluation.includes(:campagne)
              .pour_beneficiaires(beneficiaires_a_fusionner.pluck(:id))
              .update_all(beneficiaire_id: beneficiaire.id)

    beneficiaires_a_fusionner.destroy_all
  end
end
