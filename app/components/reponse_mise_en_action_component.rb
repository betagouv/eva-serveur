class ReponseMiseEnActionComponent < ViewComponent::Base
  def initialize(evaluation:, reponse:)
    @evaluation = evaluation
    @reponse = reponse
    @mise_en_action = evaluation.mise_en_action
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def classe_reponse
    reponse_affichee? ? "d-flex" : "hidden"
  end

  def titre
    t("reponse_mise_en_action.titre_#{@reponse}")
  end

  def detail
    return revue_prevue if @reponse == MiseEnAction::REPONSE_JE_NE_SAIS_PAS

    @mise_en_action&.libelle_qualification
  end

  def date_reponse
    return if @mise_en_action&.repondue_le.blank?

    t("reponse_mise_en_action.repondue_le",
      date: l(@mise_en_action.repondue_le.to_date, format: :short))
  end

  def classe_detail
    detail.present? ? "tag" : "tag hidden"
  end

  private

  def reponse_affichee?
    case @reponse
    when true then @mise_en_action_presenter.effectuee_avec_remediation?
    when false then @mise_en_action_presenter.non_effectuee_avec_difficulte?
    else @mise_en_action_presenter.je_ne_sais_pas_affiche?
    end
  end

  def revue_prevue
    return if @mise_en_action&.date_revue.blank?

    t("reponse_mise_en_action.revue_prevue", date: l(@mise_en_action.date_revue))
  end
end
