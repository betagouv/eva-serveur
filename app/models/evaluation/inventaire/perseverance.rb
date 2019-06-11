# frozen_string_literal: true

module Evaluation
  class Inventaire
    class Perseverance < Evaluation::Competence::Base
      def niveau
        if @evaluation.reussite?
          niveau_evaluation_reussie
        elsif un_essai || essai_avec_de_bonnes_reponses_en_moins_22_min
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def niveau_evaluation_reussie
        if @evaluation.temps_total > 22.minutes.to_i
          ::Competence::NIVEAU_4
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def un_essai
        @evaluation.nombre_essais_validation == 1
      end

      def essai_avec_de_bonnes_reponses_en_moins_22_min
        @evaluation.nombre_essais_validation.positive? &&
          @evaluation.essais_verifies.last.nombre_erreurs < 8 &&
          @evaluation.temps_total < 22.minutes.to_i
      end
    end
  end
end
