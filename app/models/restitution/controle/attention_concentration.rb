module Restitution
  class Controle
    class AttentionConcentration < Restitution::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        nombre_loupees = @restitution.nombre_loupees
        case nombre_loupees
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
