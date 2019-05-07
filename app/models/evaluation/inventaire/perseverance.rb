# frozen_string_literal: true

module Evaluation
  class Inventaire
    class Perseverance < Evaluation::Competence::Base
      def niveau
        if @evaluation.reussite? && @evaluation.temps_total > 22.minutes.to_i
          ::Competence::NIVEAU_4
        elsif @evaluation.abandon? &&
              (un_essai_avec_erreur || essai_avec_bonne_reponse_en_moins_22_min)
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def un_essai_avec_erreur
        @evaluation.nombre_essais_validation == 1 &&
          @evaluation.essais.first.nombre_erreurs > 0
      end

      def essai_avec_bonne_reponse_en_moins_22_min
        @evaluation.nombre_essais_validation > 0 &&
          @evaluation.essais.last.nombre_erreurs < 8 &&
          @evaluation.temps_total < 22.minutes.to_i
      end
    end
  end
end
