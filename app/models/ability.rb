class Ability < AbilityUtilisateur
  def initialize(compte)
    return unless compte

    if compte.validation_refusee?
      droits_comptes_refuses compte
    elsif compte.en_attente_restreint?
      droits_comptes_en_attente_restreints compte
    elsif compte.vue_opco_active?
      droits_comptes_opco_restreints compte
    else
      super
      droits_applicatifs
    end
  end

  private

  def droits_applicatifs
    droit_situation
    droit_question
    droit_questionnaire
    droit_choix
    droit_page
  end

  def droit_situation
    can :read, Situation
    cannot :destroy, Situation do |s|
      SituationConfiguration.exists?(situation: s)
    end
  end

  def droit_questionnaire
    can :read, Questionnaire
    cannot :destroy, Questionnaire do |q|
      Situation.where(questionnaire: q)
               .or(Situation.where(questionnaire_entrainement: q))
               .exists?
    end
  end

  def droit_question
    can :read, Question
    cannot :destroy, Question do |q|
      QuestionnaireQuestion.exists?(question: q) ||
        (q.created_at && q.created_at < 1.month.ago)
    end
  end

  def droit_choix
    cannot :destroy, Choix do |c|
      c.created_at < 1.month.ago
    end
  end

  def droit_page
    can :read, ActiveAdmin::Page, name: "Aide", namespace_name: "admin"
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
  end

  def droits_comptes_refuses(compte)
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
    can %i[update read accepter_cgu], compte
  end

  def droits_comptes_en_attente_restreints(compte)
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
    can :read, ActiveAdmin::Page, name: "Aide", namespace_name: "admin"
    can :read, Actualite
    can %i[update read accepter_cgu], compte
  end

  def droits_comptes_opco_restreints(compte)
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
    can :read, ActiveAdmin::Page, name: "Aide", namespace_name: "admin"
    can :read, Actualite
    can %i[read update accepter_cgu], compte
    can :read, Structure, id: compte.structure_id
    structure_ids = compte.admin? ? compte.structure.subtree_ids : [ compte.structure_id ]
    can %i[envoyer_invitation copier_lien], StructureLocale, id: structure_ids
    can %i[envoyer_invitation copier_lien], StructureAdministrative, id: structure_ids
    can :read, Compte, structure_id: compte.structure_id
  end
end
