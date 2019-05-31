# frozen_string_literal: true

module Evaluation
  class Tri
    class Rapidite < Evaluation::Competence::Base
      def niveau
        temps_total = @evaluation.temps_total
        case temps_total
        when 0..120 then ::Competence::NIVEAU_4
        when 0..180 then ::Competence::NIVEAU_3
        when 0..240 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
