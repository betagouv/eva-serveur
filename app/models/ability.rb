# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    droit_generiques
    cannot :manage, Compte unless compte.administrateur?
  end

  private

  def droit_generiques
    can :manage, :all
    cannot %i[destroy create], Evaluation
    cannot %i[update create], Evenement
  end
end
