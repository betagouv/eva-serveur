# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    droits_generiques
    droit_campagne compte
    droit_evaluation compte
    droit_evenement compte
    droit_situation compte
    droit_question compte
    droit_questionnaire compte
    cannot :manage, Compte unless compte.administrateur?
  end

  private

  def droit_campagne(compte)
    cannot :manage, Campagne unless compte.administrateur?
    can :create, Campagne
    can %i[update read destroy], Campagne, compte_id: compte.id
  end

  def droit_evaluation(compte)
    cannot :manage, Evaluation unless compte.administrateur?
    can :manage, Evaluation, campagne: { compte_id: compte.id }
  end

  def droit_evenement(compte)
    cannot %i[update create], Evenement
    cannot :read, Evenement unless compte.administrateur?
    can :read, Evenement, evaluation: { campagne: { compte_id: compte.id } }
  end

  def droit_situation(compte)
    cannot :manage, Situation unless compte.administrateur?
    can :read, Situation
  end

  def droit_questionnaire(compte)
    cannot :manage, Questionnaire unless compte.administrateur?
    can :read, Questionnaire
    cannot :destroy, Questionnaire do |q|
      Campagne.where(questionnaire: q).present?
    end
  end

  def droit_question(compte)
    cannot :manage, Question unless compte.administrateur?
    can :read, Question
  end

  def droits_generiques
    can :manage, :all
  end
end
