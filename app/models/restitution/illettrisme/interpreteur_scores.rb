# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      def initialize(scores)
        @scores = scores
      end

      def interpretations
        interpretations = self.class::PALIERS.keys.map { |score| { score => interprete(score) } }
        applique_exceptions!(interpretations)

        interpretations
      end

      def interprete(competence)
        score = @scores[competence]
        return if score.blank?

        if score < -1
          self.class::PALIERS[competence][0]
        elsif score.negative?
          self.class::PALIERS[competence][1]
        else
          self.class::PALIERS[competence][2]
        end
      end

      def applique_exceptions!(interpretations); end
    end
  end
end
