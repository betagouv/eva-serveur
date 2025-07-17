# frozen_string_literal: true

class MenuBoutonsActionComponent < ViewComponent::Base
  def initialize(*actions)
    @actions = actions
  end
end
