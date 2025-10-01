module Restitution
  class Tri
    class ComprehensionConsigne < Restitution::Competence::Base
      attr_reader :restitution

      delegate :termine?, to: :restitution
      delegate :nombre_bien_placees, :nombre_mal_placees, to: :restitution
      delegate :nombre_rejoue_consigne, to: :restitution

      def niveau
        if termine?
          evalue_termine
        elsif consigne_mal_comprise
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def evalue_termine
        if nombre_mal_placees < 8
          ::Competence::NIVEAU_4
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def consigne_mal_comprise
        nombre_bien_placees + nombre_mal_placees < 8 &&
          nombre_mal_placees&.positive? &&
          nombre_rejoue_consigne.positive?
      end
    end
  end
end
