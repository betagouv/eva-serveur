# frozen_string_literal: true

module EvaluationHelper
  def niveau_bas?(profil)
    ::Competence::PROFILS_BAS.include?(profil)
  end

  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == 'illettrisme_potentiel'
    liste_filtree_illettrisme_potentiel ? false : true
  end

  def effectuee_avec_dispositif_remediation?(ressource)
    ressource&.mise_en_action&.effectuee_avec_dispositif_remediation?
  end

  def effectuee_sans_dispositif_remediation?(ressource)
    ressource&.mise_en_action&.effectuee &&
      ressource&.mise_en_action&.dispositif_de_remediation.blank?
  end

  def non_effectuee_sans_difficulte?(ressource)
    ressource&.mise_en_action&.effectuee == false &&
      ressource&.mise_en_action&.difficulte.blank?
  end

  def non_effectuee_avec_difficulte?(ressource)
    ressource&.mise_en_action&.non_effectuee_avec_difficulte?
  end

  def mise_en_action_avec_qualification?(ressource)
    effectuee_avec_dispositif_remediation?(ressource) || non_effectuee_avec_difficulte?(ressource)
  end
end
