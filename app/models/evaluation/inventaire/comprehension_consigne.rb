# frozen_string_literal: true

module Evaluation
  class Inventaire
    class ComprehensionConsigne < Evaluation::Competence::Base
      def niveau
        if @evaluation.reussite?
          ::Competence::NIVEAU_4
        elsif @evaluation.abandon? &&
              (un_essai_avec_8_erreurs || @evaluation.nombre_rejoue_consigne >= 2)
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def un_essai_avec_8_erreurs
        @evaluation.nombre_essais_validation == 1 && @evaluation.essais.first.nombre_erreurs == 8
      end
    end
  end
end
