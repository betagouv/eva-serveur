# frozen_string_literal: true

module Evaluations
  class PassationBeneficiaire
    attr_reader :evaluation

    def initialize(evaluation)
      @evaluation = evaluation
    end

    def evapro?
      false
    end
  end
end

