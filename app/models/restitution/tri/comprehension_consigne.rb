# frozen_string_literal: true

module Restitution
  class Tri
    class ComprehensionConsigne < Restitution::Competence::Base
      attr_reader :restitution
      delegate :termine?, :nombre_mal_placees, :nombre_rejoue_consigne, to: :restitution

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
