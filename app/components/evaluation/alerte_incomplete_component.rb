# frozen_string_literal: true

class Evaluation
  class AlerteIncompleteComponent < ViewComponent::Base
    def initialize
      @titre = 'admin.restitutions.numeratie.alerte_incomplete.titre'
      @body = 'admin.restitutions.numeratie.alerte_incomplete.body'
    end
  end
end
