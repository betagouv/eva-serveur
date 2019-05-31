# frozen_string_literal: true

module Evaluation
  class Tri
    class ComprehensionConsigne < Evaluation::Competence::Base
      attr_reader :evaluation
      delegate :termine?, :nombre_mal_placees, :nombre_rejoue_consigne, to: :evaluation

      def niveau
        if termine? && nombre_mal_placees < 8
          ::Competence::NIVEAU_4
        elsif !termine? && nombre_mal_placees < 8 && nombre_rejoue_consigne >= 2
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end
    end
  end
end
