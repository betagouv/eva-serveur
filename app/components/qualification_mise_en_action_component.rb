class QualificationMiseEnActionComponent < ViewComponent::Base
  def initialize(evaluation:, questionnaire:)
    @evaluation = evaluation
    @questionnaire = MiseEnAction::Questionnaire.new(questionnaire)
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def nom
    @questionnaire.nom
  end

  def choix
    @questionnaire.reponses.values
  end

  def libelle_choix(choix)
    t("activerecord.attributes.mise_en_action.#{nom}.#{choix}")
  end

  def classe_qualification
    qualification_attendue? ? "" : "hidden"
  end

  private

  def qualification_attendue?
    if nom == :remediation
      @mise_en_action_presenter.effectuee_sans_remediation?
    else
      @mise_en_action_presenter.non_effectuee_sans_difficulte?
    end
  end
end
