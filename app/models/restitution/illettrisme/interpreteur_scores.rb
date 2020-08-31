# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      def initialize(scores)
        @scores = scores
      end

      def interpretations(competences)
        competences.map do |competence, niveaux|
          { competence => interprete(competence, niveaux) }
        end
      end

      def interprete(competence, niveaux)
        score = @scores[competence]
        return if score.blank?

        if score < -1
          niveaux[0]
        elsif score.negative?
          niveaux[1]
        else
          niveaux[2]
        end
      end
    end
  end
end
