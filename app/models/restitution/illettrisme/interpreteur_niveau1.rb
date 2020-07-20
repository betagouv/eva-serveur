# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      PALIERS = {
        litteratie: %i[litteratie_a1 litteratie_a2 litteratie_b1],
        numeratie: %i[numeratie_x1 numeratie_x2 numeratie_y1]
      }.freeze

      def initialize(scores)
        @scores = scores
      end

      def interpretations
        interpretations = [interprete(:litteratie), interprete(:numeratie)].compact
        return [:socle_clea_atteint] if interpretations == %i[litteratie_b1 numeratie_y1]

        interpretations
      end

      def interprete(competence)
        score = @scores[competence]
        return if score.blank?

        if score < -1
          PALIERS[competence][0]
        elsif score.negative?
          PALIERS[competence][1]
        else
          PALIERS[competence][2]
        end
      end
    end
  end
end
