class QuestionMiseEnActionComponent < ViewComponent::Base
  TRADUCTIONS_BOUTONS = {
    true => "bouton_oui",
    false => "bouton_non",
    MiseEnAction::REPONSE_JE_NE_SAIS_PAS => "bouton_je_ne_sais_pas"
  }.freeze

  def initialize(evaluation:, reponses:)
    @evaluation = evaluation
    @reponses = reponses
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def classe_question
    question_affichee? ? "d-flex" : "hidden"
  end

  # À la date de revue, la question est reposée en rappelant la réponse Pas encore
  def rappel_pas_encore
    return unless @mise_en_action_presenter.rappel_pas_encore?

    t("question_mise_en_action.rappel_pas_encore",
      date: l(@evaluation.mise_en_action.repondue_le.to_date, format: :short))
  end

  def libelle_bouton(reponse)
    t("question_mise_en_action.#{TRADUCTIONS_BOUTONS[reponse]}")
  end

  private

  def question_affichee?
    !(@mise_en_action_presenter.reponse_affichee? ||
      @mise_en_action_presenter.effectuee_sans_remediation? ||
      @mise_en_action_presenter.non_effectuee_sans_difficulte? ||
      @mise_en_action_presenter.date_revue_a_choisir?)
  end
end
