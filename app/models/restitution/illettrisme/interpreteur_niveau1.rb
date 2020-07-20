# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1 < InterpreteurScores
      PALIERS = {
        litteratie: %i[litteratie_a1 litteratie_a2 litteratie_b1],
        numeratie: %i[numeratie_x1 numeratie_x2 numeratie_y1]
      }.freeze

      def applique_exceptions!(interpretations)
        socle_clea = %i[litteratie_b1 numeratie_y1]
        return unless interpretations == socle_clea

        interpretations.reject! { |e| socle_clea.include?(e) }
        interpretations << :socle_clea_atteint
      end
    end
  end
end
