# frozen_string_literal: true

class BoutonMenuActionsComponent < ViewComponent::Base
  def initialize(*actions)
    @actions = actions
  end
end
