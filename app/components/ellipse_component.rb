# frozen_string_literal: true

class EllipseComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(statut)
    @statut = statut.to_sym
  end
end
