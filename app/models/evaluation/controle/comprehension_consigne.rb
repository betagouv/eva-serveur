# frozen_string_literal: true

module Evaluation
  class Controle
    class ComprehensionConsigne < Evaluation::Competence::Base
      def niveau
        if @evaluation.termine? && @evaluation.nombre_loupees < 16
          ::Competence::NIVEAU_4
        elsif @evaluation.termine? || abandon_en_moins_de_11_pieces_avec_erreurs?
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def abandon_en_moins_de_11_pieces_avec_erreurs?
        @evaluation.abandon? && nombre_pieces < 11 && @evaluation.nombre_loupees.positive? &&
          @evaluation.nombre_rejoue_consigne.positive?
      end

      def nombre_pieces
        @evaluation.nombre_bien_placees + @evaluation.nombre_loupees
      end
    end
  end
end
