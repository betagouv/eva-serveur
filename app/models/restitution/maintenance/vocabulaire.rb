# frozen_string_literal: true

module Restitution
  class Maintenance
    class Vocabulaire < Restitution::Competence::Base
      def niveau
        score = @restitution.score
        if score > -0.4 then ::Competence::NIVEAU_1
        elsif score > -2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_3
        end
      end
    end
  end
end
