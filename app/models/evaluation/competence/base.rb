# frozen_string_literal: true

module Evaluation
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
end
