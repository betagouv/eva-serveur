# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
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

        if illettrisme_potentiel(competence, score)
          :palier0
        elsif score < -1
          :palier1
        elsif score.negative?
          :palier2
        else
          :palier3
        end
      end

      def illettrisme_potentiel(competence, score)
        competence == :litteratie && score <= -3.55 ||
          competence == :numeratie && score <= -1.64
      end
    end
  end
end
