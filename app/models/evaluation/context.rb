# frozen_string_literal: true

class Evaluation
  class Context
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def pro?
      @evaluation.campagne.parcours_type.diagnostic_entreprise?
    end

    def usage_beneficiaire?
      !pro?
    end
  end
end
