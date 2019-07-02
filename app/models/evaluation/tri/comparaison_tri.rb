# frozen_string_literal: true

module Evaluation
  class Tri
    class ComparaisonTri < Evaluation::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @evaluation.termine?

        case @evaluation.nombre_mal_placees
        when 0 then ::Competence::NIVEAU_4
        when 1..2 then ::Competence::NIVEAU_3
        when 3 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
