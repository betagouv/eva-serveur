# frozen_string_literal: true

module Evaluation
  class Controle
    class Perseverance < Evaluation::Competence::Base
      def niveau
        if @evaluation.termine?
          ::Competence::NIVEAU_4
        elsif @evaluation.nombre_bien_placees >= 8 && @evaluation.evenements_pieces.size >= 15
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end
    end
  end
end
