# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    droits_generiques compte
    droit_campagne compte
    droit_evaluation compte
    droit_evenement compte
    droit_restitution compte
    droit_situation
    droit_question
    droit_questionnaire
  end

  private

  def droit_campagne(compte)
    can :create, Campagne
    can :manage, Campagne, compte_id: compte.id
  end

  def droit_evaluation(compte)
    cannot %i[create update], Evaluation
    can %i[read destroy], Evaluation, campagne: { compte_id: compte.id }
  end

  def droit_evenement(compte)
    cannot %i[update create], Evenement
    can :read, Evenement, partie: { evaluation: { campagne: { compte_id: compte.id } } }
  end

  def droit_restitution(compte)
    can :manage, Restitution::Base, campagne: { compte_id: compte.id }
  end

  def droit_situation
    can :read, Situation
  end

  def droit_questionnaire
    can :read, Questionnaire
    cannot :destroy, Questionnaire do |q|
      Campagne.where(questionnaire: q).present?
    end
  end

  def droit_question
    can :read, Question
  end

  def droits_generiques(compte)
    can :manage, :all if compte.administrateur?
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
  end
end
