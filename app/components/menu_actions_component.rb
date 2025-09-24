# frozen_string_literal: true

class MenuActionsComponent < ViewComponent::Base
  include CanCan::ControllerAdditions

  def initialize(ressource, *actions)
    @ressource = ressource
    @actions = actions
  end

  delegate :can?, :current_user, to: :helpers
end
