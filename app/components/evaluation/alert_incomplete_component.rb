# frozen_string_literal: true

class Evaluation
  class AlertIncompleteComponent < ViewComponent::Base
    def initialize
      @scope = "admin.restitutions.numeratie.alert_incomplete"
    end
  end
end
