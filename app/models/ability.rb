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
    droit_compte
    droit_choix
  end

  private

  def droit_campagne(compte)
    can :create, Campagne
    can %i[create update read], Campagne, compte_id: compte.id
    can :destroy, Campagne do |c|
      Evaluation.where(campagne: c).count.zero?
    end
  end

  def droit_evaluation(compte)
    cannot %i[create update], Evaluation
    can %i[read destroy], Evaluation, campagne: { compte_id: compte.id }
  end

  def droit_evenement(compte)
    cannot %i[update create], Evenement

    @session_ids ||= Partie.where('campagnes.compte_id' => compte.id)
                           .joins(evaluation: :campagne).pluck(:session_id)
    can :read, Evenement, Evenement.where(session_id: @session_ids) do |e|
      @session_ids.include?(e.session_id)
    end
  end

  def droit_restitution(compte)
    can :manage, Restitution::Base, campagne: { compte_id: compte.id }
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
      Campagne.where(questionnaire: q).present? ||
        Situation.where(questionnaire: q)
                 .or(Situation.where(questionnaire_entrainement: q))
                 .present?
    end
  end

  def droit_question
    can :read, Question
    cannot :destroy, Question do |q|
      QuestionnaireQuestion.where(question: q).present? ||
        Evenement.where("donnees->>'question' = ?", q.id.to_s).present?
    end
  end

  def droit_compte
    cannot :destroy, Compte do |q|
      Campagne.where(compte: q).present?
    end
  end

  def droit_choix
    cannot :destroy, Choix do |c|
      Evenement.where("donnees->>'reponse' = ?", c.id.to_s).present?
    end
  end

  def droits_generiques(compte)
    can :manage, :all if compte.administrateur?
    cannot :destroy, Campagne
    can :read, ActiveAdmin::Page, name: 'Dashboard', namespace_name: 'admin'
  end
end
