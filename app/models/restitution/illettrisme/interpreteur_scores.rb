# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      def initialize(scores)
        @scores = scores
      end

      def interpretations(competences)
        competences.map do |competence|
          { competence => interprete(competence) }
        end
      end

      def interprete(competence)
        score = @scores[competence]
        return if score.blank?

        if score < -1
          :palier1
        elsif score.negative?
          :palier2
        else
          :palier3
        end
      end
    end
  end
end
