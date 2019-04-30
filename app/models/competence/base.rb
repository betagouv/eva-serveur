# frozen_string_literal: true

module Competence
  class Base
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def niveau
      raise NotImplementedError
    end
  end
end
