# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1 < InterpreteurScores
      PALIERS = {
        litteratie: %i[a1 a2 b1],
        numeratie: %i[x1 x2 y1]
      }.freeze

      def applique_exceptions!(interpretations)
        return unless interpretations == [{ litteratie: :b1 }, { numeratie: :y1 }]

        interpretations.reject! { |(e)| %i[litteratie numeratie].include?(e.keys.first) }
        interpretations << { socle_clea: :atteint }
      end
    end
  end
end
