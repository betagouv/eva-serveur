# frozen_string_literal: true

class Ability < AbilityUtilisateur
  include CanCan::Ability

  def initialize(compte)
    droits_comptes_refuses compte
    return if compte.validation_refusee?

    super
    droits_applicatifs
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
    can :read, ActiveAdmin::Page
  end

  def droits_comptes_refuses(compte)
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
    can %i[update read], compte
  end
end
