# frozen_string_literal: true

module Evaluation
  class Inventaire
    class OrganisationMethode < Evaluation::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE unless @evaluation.reussite?

        nombre_ouverture_contenant = @evaluation.nombre_ouverture_contenant
        case nombre_ouverture_contenant
        when 0..70 then ::Competence::NIVEAU_4
        when 70..120 then ::Competence::NIVEAU_3
        when 120..250 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
