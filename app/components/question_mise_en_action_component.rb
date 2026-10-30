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
    @mise_en_action_presenter.reponse_affichee? ? "hidden" : "d-flex"
  end

  def classe_bouton(reponse)
    bouton_actif = @mise_en_action_presenter.a_mise_en_action? &&
                   @evaluation.mise_en_action.effectuee == reponse
    bouton_actif ? "reponse-mise-en-action bouton--actif" : "reponse-mise-en-action"
  end

  def libelle_bouton(reponse)
    t("components.reponse_mise_en_action.#{TRADUCTIONS_BOUTONS[reponse]}")
  end
end
