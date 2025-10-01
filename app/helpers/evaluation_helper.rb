module EvaluationHelper
  def niveau_bas?(profil)
    ::Competence::PROFILS_BAS.include?(profil)
  end

  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == "illettrisme_potentiel"
    liste_filtree_illettrisme_potentiel ? false : true
  end

  def effectuee_avec_remediation?(ressource)
    ressource&.mise_en_action&.effectuee_avec_remediation?
  end

  def effectuee_sans_remediation?(ressource)
    ressource&.mise_en_action&.effectuee &&
      ressource&.mise_en_action&.remediation.blank?
  end

  def non_effectuee_sans_difficulte?(ressource)
    ressource&.mise_en_action&.effectuee == false &&
      ressource&.mise_en_action&.difficulte.blank?
  end

  def non_effectuee_avec_difficulte?(ressource)
    ressource&.mise_en_action&.non_effectuee_avec_difficulte?
  end

  def mise_en_action_avec_qualification?(ressource)
    effectuee_avec_remediation?(ressource) || non_effectuee_avec_difficulte?(ressource)
  end

  def diag_risques_entreprise
    restitution_pour_situation(Situation::DIAG_RISQUES_ENTREPRISE)
  end

  def cafe_de_la_place
    restitution_pour_situation(Situation::CAFE_DE_LA_PLACE)
  end

  def place_du_marche
    restitution_pour_situation(Situation::PLACE_DU_MARCHE)
  end

  def badge_positionnement(evaluation, competence)
    if evaluation.campagne.avec_positionnement?(competence)
      niveau = evaluation.send("positionnement_niveau_#{competence}")
    else
      niveau = nil
    end

    construit_badge(niveau, competence)
  end

  private

  def construit_badge(niveau, competence)
    render(Badge::ProfilComponent.new(niveau, competence))
  end
end
