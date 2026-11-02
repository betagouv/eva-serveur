class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def reponses
    reponses = [ true, false ]
    reponses << MiseEnAction::REPONSE_JE_NE_SAIS_PAS if MiseEnAction.je_ne_sais_pas_actif?
    reponses
  end

  def qcm_remediation
    Qcm.new(@evaluation, MiseEnAction::Questionnaire.new(:remediation),
            qcm_affiche: @mise_en_action_presenter.effectuee_sans_remediation?)
  end

  def qcm_difficulte
    Qcm.new(@evaluation, MiseEnAction::Questionnaire.new(:difficulte),
            qcm_affiche: @mise_en_action_presenter.non_effectuee_sans_difficulte?)
  end
end
