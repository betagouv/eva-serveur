# frozen_string_literal: true

class NomAnonymisableComponent < ViewComponent::Base
  def initialize(ressource)
    @ressource = ressource
  end
end
