# frozen_string_literal: true

class MenuActionsComponent < ViewComponent::Base
  def initialize(*actions)
    @actions = actions
  end
end
