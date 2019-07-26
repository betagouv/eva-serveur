# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    can :manage, :all
    cannot :manage, Compte unless compte.administrateur?
  end
end
