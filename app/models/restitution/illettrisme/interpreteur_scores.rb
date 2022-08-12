# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      PALIERS = {
        CEFR: {
          litteratie: [-1.5, -1, 0],
          numeratie: [-1, -0.5, 0]
        },
        ANLCI: {
          litteratie: [-2, -1.5, -1, -0.5, 0],
          numeratie: [-1, -0.5, 0, 0.5, 1]
        },
        TOUT_REFERENTIEL: {
          score_ccf: [-1, 0],
          score_syntaxe_orthographe: [-1, 0],
          score_memorisation: [-1, 0],
          score_numeratie: [-1, 0]
        }
      }.freeze

      def initialize(scores)
        @scores = scores
      end

      def interpretations(competences, referentiel = :TOUT_REFERENTIEL)
        competences.map do |competence|
          { competence => interprete(competence,
                                     referentiel,
                                     @scores[competence]) }
        end
      end

      private

      def interprete(competence, referentiel, score)
        return if score.blank?

        PALIERS[referentiel][competence].each_with_index do |palier, index|
          return "palier#{index}".to_sym if score <= palier
        end

        "palier#{PALIERS[referentiel][competence].count}".to_sym
      end
    end
  end
end
