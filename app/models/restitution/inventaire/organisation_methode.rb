module Restitution
  class Inventaire
    class OrganisationMethode < Restitution::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @restitution.reussite?

        @nombre_ouverture_contenant = @restitution.nombre_ouverture_contenant
        @restitution.version?(VERSION_2) ? niveau_version2 : niveau_version1
      end

      private

      def niveau_version2
        case @nombre_ouverture_contenant
        when 0..42 then ::Competence::NIVEAU_4
        when 43..71 then ::Competence::NIVEAU_3
        when 72..148 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end

      def niveau_version1
        case @nombre_ouverture_contenant
        when 0..70 then ::Competence::NIVEAU_4
        when 71..120 then ::Competence::NIVEAU_3
        when 121..250 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
