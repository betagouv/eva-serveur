module Restitution
  class Controle
    class ComprehensionConsigne < Restitution::Competence::Base
      def niveau
        if @restitution.termine? && @restitution.nombre_loupees < 16
          ::Competence::NIVEAU_4
        elsif @restitution.termine? || abandon_en_moins_de_11_pieces_avec_erreurs?
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def abandon_en_moins_de_11_pieces_avec_erreurs?
        @restitution.abandon? && nombre_pieces < 11 && @restitution.nombre_loupees.positive? &&
          @restitution.nombre_rejoue_consigne.positive?
      end

      def nombre_pieces
        @restitution.nombre_bien_placees + @restitution.nombre_loupees
      end
    end
  end
end
