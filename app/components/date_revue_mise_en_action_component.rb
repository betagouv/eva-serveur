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

  def id_champ_date
    "date-revue-#{@evaluation.id}"
  end

  # Comme "Autre" pour Oui et Non : seule une date précise est retrouvée, avec sa date
  def date_precise_choisie?
    @evaluation.mise_en_action&.choix_date_revue == MiseEnAction::CHOIX_DATE_PRECISE
  end

  def classe_zone_date
    date_precise_choisie? ? "" : "zone-date-revue--masquee"
  end

  def date_revue_precise
    @evaluation.mise_en_action.date_revue if date_precise_choisie?
  end
end
