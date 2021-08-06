# frozen_string_literal: true

class Ability # rubocop:disable Metrics/ClassLength
  include CanCan::Ability

  def initialize(compte)
    droits_utilisateur compte
    droits_applicatifs
  end

  private

  def droits_utilisateur(compte)
    droits_generiques compte
    droit_campagne compte
    droit_evaluation compte
    droit_evenement compte
    droit_restitution compte
    droit_compte compte
    droit_structure compte
  end

  def droits_applicatifs
    droit_situation
    droit_question
    droit_questionnaire
    droit_choix
    droit_actualite
    droit_page
  end

  def droit_campagne(compte)
    can :create, Campagne
    can %i[update read], Campagne, comptes_de_meme_structure(compte) if compte.validation_acceptee?
    can %i[update read], Campagne, compte_id: compte.id
    can :destroy, Campagne do |c|
      Evaluation.where(campagne: c).count.zero?
    end
  end

  def droit_evaluation(compte)
    cannot %i[create], Evaluation
    if compte.validation_acceptee?
      can %i[read destroy], Evaluation,
          campagne: comptes_de_meme_structure(compte)
    end
    can %i[read destroy], Evaluation, campagne: { compte_id: compte.id }
    can %i[update], Evaluation, campagne: comptes_de_meme_structure(compte) if compte.admin?
  end

  def droit_evenement(compte)
    cannot %i[update create], Evenement

    @session_ids ||= Partie.where('comptes.structure_id' => compte.structure_id)
                           .joins(evaluation: { campagne: :compte }).pluck(:session_id)
    can :read, Evenement, Evenement.where(session_id: @session_ids) do |e|
      @session_ids.include?(e.session_id)
    end
  end

  def droit_restitution(compte)
    can :manage, Restitution::Base, campagne: comptes_de_meme_structure(compte)
  end

  def droit_situation
    can :read, Situation
    cannot :destroy, Situation do |s|
      SituationConfiguration.where(situation: s).count.positive?
    end
  end

  def droit_questionnaire
    can :read, Questionnaire
    cannot :destroy, Questionnaire do |q|
      Campagne.where(questionnaire: q).exists? ||
        Situation.where(questionnaire: q)
                 .or(Situation.where(questionnaire_entrainement: q))
                 .exists?
    end
  end

  def droit_question
    can :read, Question
    cannot :destroy, Question do |q|
      QuestionnaireQuestion.where(question: q).exists? ||
        Evenement.where("donnees->>'question' = ?", q.id.to_s).exists?
    end
  end

  def droit_compte(compte)
    can :read, Compte, structure_id: compte.structure_id if compte.validation_acceptee?
    can :update, Compte, structure_id: compte.structure_id if compte.admin?
    can :read, compte
    can :update, compte
    can :create, Compte if compte.admin? || compte.compte_generique?
    can :edit_role, Compte if compte.admin?
    cannot(:destroy, Compte) { |c| Campagne.where(compte: c).exists? }
  end

  def droit_choix
    cannot :destroy, Choix do |c|
      Evenement.where("donnees->>'reponse' = ?", c.id.to_s).exists?
    end
  end

  def droit_structure(compte)
    can :read, Structure, id: compte.structure_id if compte.validation_acceptee?
    can :update, Structure, id: compte.structure_id if compte.admin?
    cannot(:destroy, Structure) { |s| Compte.where(structure: s).exists? }
  end

  def droit_actualite
    can :read, Actualite
  end

  def droit_page
    can :read, ActiveAdmin::Page
  end

  def droits_generiques(compte)
    can :manage, :all if compte.superadmin?
    cannot :destroy, Campagne
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
    can :create, Contact
  end

  def comptes_de_meme_structure(compte)
    { compte: { structure_id: compte.structure_id } }
  end
end
