# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      def initialize(scores)
        @interpreteur_score = InterpreteurScores.new(scores)
      end

      def interpretations
        applique_exceptions(
          @interpreteur_score.interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1)
        )
      end

      def applique_exceptions(interpretations)
        if interpretations == [{ litteratie: :palier3 }, { numeratie: :palier3 }]
          return [{ socle_clea: :description }]
        end

        interpretations
      end
    end
  end
end
