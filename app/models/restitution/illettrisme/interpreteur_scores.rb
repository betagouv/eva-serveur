# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      SEUILS_PALIER0 = {
        litteratie: -3.55,
        numeratie: -1.64
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

        if palier0?(competence, score)
          :palier0
        elsif score < -1
          :palier1
        elsif score.negative?
          :palier2
        else
          :palier3
        end
      end

      def palier0?(competence, score)
        SEUILS_PALIER0.key?(competence) && score <= SEUILS_PALIER0[competence]
      end
    end
  end
end
