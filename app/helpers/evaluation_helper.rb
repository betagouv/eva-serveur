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

  def score_to_lettre(score)
    {
      "faible" => "a",
      "moyen" => "b",
      "fort" => "c",
      "tres_fort" => "d"
    }.fetch(score.to_s, score.to_s)
  end

  def contenu_cout(synthese)
    lettre = score_to_lettre(synthese[:score_cout])
    {
      titre: t("admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.titre.#{lettre}"),
      texte: t("admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.texte"),
      suite: t("admin.evaluations.mesure_des_impacts.impact_couts.contenu_cout.suite.#{lettre}")
    }
  end

  def explication_strategie(synthese)
    lettre = score_to_lettre(synthese[:score_strategie])
    base_path = "admin.evaluations.mesure_des_impacts.impact_couts.explications_strategies"
    {
      titre: t("#{base_path}.titre.#{lettre}"),
      texte: t("#{base_path}.texte.#{lettre}")
    }
  end

  def explication_numerique(synthese)
    lettre = score_to_lettre(synthese[:score_numerique])
    base_path = "admin.evaluations.mesure_des_impacts.impact_couts.explications_numerique"
    {
      titre: t("#{base_path}.titre.#{lettre}"),
      texte: t("#{base_path}.texte.#{lettre}")
    }
  end

  def lettre_score_strategie(synthese)
    score_to_lettre(synthese[:score_strategie])
  end

  def lettre_score_numerique(synthese)
    score_to_lettre(synthese[:score_numerique])
  end

  def titre_evaluation(evaluation)
    if evaluation.opco_financeur
      evaluation.structure&.nom
    else
      render NomAnonymisableComponent.new(evaluation.beneficiaire)
    end
  end
end
