# frozen_string_literal: true

module Restitution
  module CompetencesTransversales
    class Interpreteur
      def initialize(niveaux_competences)
        @niveaux_competences = niveaux_competences
      end

      def interpretations
        @niveaux_competences.map do |competence, niveau|
          [ competence, interprete(niveau) ]
        end
      end

      def interprete(niveau)
        case niveau
        when 4 then 3
        when 1 then 1
        else 2
        end
      end
    end
  end
end
