class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def classe_bandeau
    if @mise_en_action_presenter.a_mise_en_action? &&
       @mise_en_action_presenter.mise_en_action_avec_qualification?
      "card__banner--succes"
    else
      "card__banner--en-attente"
    end
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
