# frozen_string_literal: true

module Evaluation
  class Tri
    class Perseverance < Evaluation::Competence::Base
      def niveau
        if niveau_4?
          ::Competence::NIVEAU_4
        elsif niveau1?
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def niveau_4?
        @evaluation.termine? && @evaluation.temps_total > 240 &&
          @evaluation.nombre_mal_placees > 5
      end

      def niveau1?
        !@evaluation.termine? && @evaluation.temps_total < 120 && @evaluation.nombre_mal_placees > 3
      end
    end
  end
end
