# frozen_string_literal: true

module Restitution
  class Controle
    class Rapidite < Restitution::Competence::Base
      def niveau
        nombre_erreur = @restitution.nombre_non_triees
        case nombre_erreur
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
