class EnteteMiseEnActionComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
  end

  def date_evaluation
    return if @evaluation.debutee_le.blank?

    t("entete_mise_en_action.evaluation_du",
      date: l(@evaluation.debutee_le.to_date, format: :short))
  end

  def resultats
    return [] if @evaluation.campagne.blank?

    resultats_positionnement + resultats_diagnostic
  end

  private

  def resultats_positionnement
    %i[litteratie numeratie].filter_map do |domaine|
      next unless @evaluation.campagne.avec_positionnement?(domaine)

      ResultatComponent.new(domaine: domaine,
                            niveau: @evaluation.send(:"positionnement_niveau_#{domaine}"))
    end
  end

  def resultats_diagnostic
    return [] unless @evaluation.campagne.avec_diagnostic?

    [ ResultatComponent.new(domaine: :francais, niveau: @evaluation.niveau_cefr),
      ResultatComponent.new(domaine: :mathematiques, niveau: @evaluation.niveau_cnef) ]
  end
end
