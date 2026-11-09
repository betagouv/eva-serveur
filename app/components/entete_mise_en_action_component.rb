class EnteteMiseEnActionComponent < ViewComponent::Base
  def initialize(evaluation:, avec_lien_evaluation: false)
    @evaluation = evaluation
    @avec_lien_evaluation = avec_lien_evaluation
  end

  def lien_evaluation?
    @avec_lien_evaluation
  end

  def chemin_evaluation
    helpers.admin_evaluation_eva_path(@evaluation)
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

      resultat(domaine, @evaluation.send(:"positionnement_niveau_#{domaine}"))
    end
  end

  def resultats_diagnostic
    return [] unless @evaluation.campagne.avec_diagnostic?

    [ resultat(:francais, @evaluation.niveau_cefr),
      resultat(:mathematiques, @evaluation.niveau_cnef) ]
  end

  def resultat(domaine, niveau)
    ResultatComponent.new(domaine: domaine, niveau: niveau, avec_titre: false)
  end
end
