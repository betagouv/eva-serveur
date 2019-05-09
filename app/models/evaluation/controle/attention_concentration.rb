# frozen_string_literal: true

module Evaluation
  class Controle
    class AttentionConcentration < Evaluation::Competence::Base
      def niveau
        nombre_loupees = @evaluation.nombre_loupees
        case nombre_loupees
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
