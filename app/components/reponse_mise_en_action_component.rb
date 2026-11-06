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
    if @reponse == MiseEnAction::REPONSE_PAS_ENCORE
      @mise_en_action&.libelle_relance_prevue
    else
      @mise_en_action&.libelle_qualification
    end
  end

  def date_reponse
    @mise_en_action&.libelle_repondue_le
  end

  # La date est toujours rendue : le JS la remplit et l'affiche après une réponse
  def classe_date
    date_reponse.present? ? "" : "hidden"
  end

  def trouver_solution?
    @reponse == false
  end

  def lien_solution
    BanniereSolutionsIllettrismeComponent.new(evaluation: @evaluation).lien
  end

  def classe_detail
    detail.present? ? "tag" : "tag hidden"
  end

  private

  def reponse_affichee?
    case @reponse
    when true then @mise_en_action_presenter.effectuee_avec_remediation?
    when false then @mise_en_action_presenter.non_effectuee_avec_difficulte?
    else @mise_en_action_presenter.pas_encore_affiche?
    end
  end
end
