module Restitution
  class Tri
    class Perseverance < Restitution::Competence::Base
      def niveau
        if niveau_4?
          ::Competence::NIVEAU_4
        elsif niveau1?
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def niveau_4?
        @restitution.termine? && @restitution.temps_total > 240 &&
          @restitution.nombre_mal_placees > 5
      end

      def niveau1?
        !@restitution.termine? &&
          @restitution.temps_total < 120 &&
          @restitution.nombre_mal_placees > 3
      end
    end
  end
end
