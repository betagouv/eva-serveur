# frozen_string_literal: true

class Evaluation
  class AlerteIncompleteComponent < ViewComponent::Base
    def initialize
      @scope = "admin.restitutions.numeratie.alerte_incomplete"
    end
  end
end
