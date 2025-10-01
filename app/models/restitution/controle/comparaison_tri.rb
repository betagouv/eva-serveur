module Restitution
  class Controle
    class ComparaisonTri < Restitution::Competence::Base
      def initialize(restitution)
        super
        @restitution_hors_4_premiers = restitution.enleve_premiers_evenements_pieces(4)
      end

      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        nombre_erreurs = @restitution_hors_4_premiers.nombre_mal_placees
        case nombre_erreurs
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
