class DateRevueMiseEnActionComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
    @mise_en_action_presenter = evaluation.mise_en_action_presenter
  end

  def classe_date_revue
    @mise_en_action_presenter.date_revue_a_choisir? ? "" : "hidden"
  end

  def delais
    MiseEnAction::DELAIS_REVUE.keys
  end

  def libelle_delai(delai)
    t("date_revue_mise_en_action.delais.#{delai}")
  end

  def id_question
    "question-date-revue-#{@evaluation.id}"
  end
end
