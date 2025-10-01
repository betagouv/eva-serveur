module Restitution
  class Tri
    class Rapidite < Restitution::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @restitution.termine?

        temps_total = @restitution.temps_total
        case temps_total
        when 0..120 then ::Competence::NIVEAU_4
        when 0..180 then ::Competence::NIVEAU_3
        when 0..240 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
