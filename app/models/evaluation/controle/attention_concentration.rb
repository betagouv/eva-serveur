# frozen_string_literal: true

module Evaluation
  class Controle
    class AttentionConcentration < Evaluation::Competence::Base
      def niveau
        nombre_erreur = @evaluation.nombre_mal_placees + @evaluation.nombre_ratees
        case nombre_erreur
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
