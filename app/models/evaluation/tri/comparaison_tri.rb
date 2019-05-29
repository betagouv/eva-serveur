# frozen_string_literal: true

module Evaluation
  class Tri
    class ComparaisonTri < Evaluation::Competence::Base
      def niveau
        case @evaluation.nombre_mal_placees
        when 0
          ::Competence::NIVEAU_4
        when 1..2
          ::Competence::NIVEAU_3
        when 3
          ::Competence::NIVEAU_2
        else
          ::Competence::NIVEAU_1
        end
      end
    end
  end
end
