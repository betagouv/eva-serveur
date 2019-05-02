# frozen_string_literal: true

module Evaluation
  class Inventaire
    class Rapidite < Evaluation::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @evaluation.reussite?

        temps_total = @evaluation.temps_total
        case temps_total
        when 0..10.minutes.to_i then ::Competence::NIVEAU_4
        when 0..15.minutes.to_i then ::Competence::NIVEAU_3
        when 0..30.minutes.to_i then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
