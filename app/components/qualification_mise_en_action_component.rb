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

  def attributs_choix(choix)
    attributs = { qualification: choix }
    return { data: attributs } unless choix == MiseEnAction::QUALIFICATION_AUTRE

    { data: attributs, aria: { pressed: autre_choisi?.to_s } }
  end

  def autre_choisi?
    mise_en_action = @evaluation.mise_en_action
    mise_en_action&.questionnaire == nom && mise_en_action.qualification_autre?
  end

  def precision_autre
    @evaluation.mise_en_action.precision_autre if autre_choisi?
  end

  def classe_precision
    autre_choisi? ? "" : "zone-precision-autre--masquee"
  end

  def id_precision
    "precision-autre-#{nom}-#{@evaluation.id}"
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
