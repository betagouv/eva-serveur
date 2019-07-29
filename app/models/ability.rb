# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    droits_generiques
    droit_campagne compte
    cannot :manage, Compte unless compte.administrateur?
  end

  private

  def droit_campagne(compte)
    cannot :manage, Campagne unless compte.administrateur?
    can :create, Campagne
    can %i[update read destroy], Campagne, compte_id: compte.id
  end

  def droits_generiques
    can :manage, :all
    cannot %i[destroy create], Evaluation
    cannot %i[update create], Evenement
  end
end
