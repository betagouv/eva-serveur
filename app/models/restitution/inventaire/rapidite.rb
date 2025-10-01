module Restitution
  class Inventaire
    class Rapidite < Restitution::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @restitution.reussite?

        @temps_total = @restitution.temps_total
        @restitution.version?(VERSION_2) ? niveau_version2 : niveau_version1
      end

      private

      def niveau_version2
        case @temps_total
        when 0..6.minutes.to_i then ::Competence::NIVEAU_4
        when 6..9.minutes.to_i then ::Competence::NIVEAU_3
        when 9..18.minutes.to_i then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end

      def niveau_version1
        case @temps_total
        when 0..10.minutes.to_i then ::Competence::NIVEAU_4
        when 10..15.minutes.to_i then ::Competence::NIVEAU_3
        when 15..30.minutes.to_i then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
