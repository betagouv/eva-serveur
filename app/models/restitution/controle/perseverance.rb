module Restitution
  class Controle
    class Perseverance < Restitution::Competence::Base
      def niveau
        if @restitution.termine?
          ::Competence::NIVEAU_4
        elsif @restitution.nombre_bien_placees >= 8 && @restitution.evenements_pieces.size >= 15
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end
    end
  end
end
