# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      PALIERS = {
        litteratie: %i[a1 a2 b1],
        numeratie: %i[x1 x2 y1]
      }.freeze

      def initialize(scores)
        @interpreteur_score = InterpreteurScores.new(scores)
      end

      def interpretations
        applique_exceptions(@interpreteur_score.interpretations(PALIERS))
      end

      def applique_exceptions(interpretations)
        if interpretations == [{ litteratie: :b1 }, { numeratie: :y1 }]
          return [{ socle_clea: :atteint }]
        end

        interpretations
      end
    end
  end
end
