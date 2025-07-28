# frozen_string_literal: true

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

  def cafe_de_la_place
    restitution_pour_situation(Situation::CAFE_DE_LA_PLACE)
  end

  def place_du_marche
    restitution_pour_situation(Situation::PLACE_DU_MARCHE)
  end

  COULEURS_BADGES_POSITIONNEMENT = {
    profil1: "fr-badge--orange-terre-battue",
    profil2: "fr-badge--orange-terre-battue",
    profil3: "fr-badge--blue-cumulus",
    profil4: "fr-badge--green-emeraude",
    profil4_plus: "fr-badge--green-emeraude",
    profil_4h: "fr-badge--green-emeraude",
    profil_4h_plus: "fr-badge--green-emeraude",
    profil_4h_plus_plus: "fr-badge--green-emeraude",
    profil_aberrant: "fr-badge--green-emeraude"
  }.freeze

  def couleur_badges_positionnement(valeur)
    COULEURS_BADGES_POSITIONNEMENT[valeur&.to_sym] || "fr-badge--grey-950"
  end

  def traduit_niveau(evaluation, interpretation)
    scope = "activerecord.attributes.evaluation.interpretations"
    niveau = evaluation.send(interpretation)
    return "Non testé" if niveau.blank?

    t("#{interpretation}.#{niveau}", scope: scope)
  end
end
