# frozen_string_literal: true

module Restitution
  module Competence
    class Base
      def initialize(restitution)
        @restitution = restitution
      end

      def niveau
        raise NotImplementedError
      end
    end
  end
end
