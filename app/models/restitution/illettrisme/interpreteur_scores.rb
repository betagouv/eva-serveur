# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      PALIERS = {
        litteratie: [-4.1, -3.18, -2.25, -1.33, -0.4],
        numeratie: [-1.68, -1, -0.33, 0.35, 1.02],
        score_ccf: [-1, 0],
        score_syntaxe_orthographe: [-1, 0],
        score_memorisation: [-1, 0],
        score_numeratie: [-1, 0]
      }.freeze

      def initialize(scores)
        @scores = scores
      end

      def interpretations(competences)
        competences.map do |competence|
          { competence => interprete(competence, @scores[competence]) }
        end
      end

      private

      def interprete(competence, score)
        return if score.blank?

        PALIERS[competence].each_with_index do |palier, index|
          return "palier#{index}".to_sym if score <= palier
        end

        "palier#{PALIERS[competence].count}".to_sym
      end
    end
  end
end
