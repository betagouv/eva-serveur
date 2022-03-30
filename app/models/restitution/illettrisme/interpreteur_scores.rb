# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      PALIERS = {
        CEFR: {
          litteratie: [-1.7, -1.2, -0.55],
          numeratie: [-1.28, -0.71, 0.1]
        },
        ANLCI: {
          litteratie: [-2.3, -1.7, -1.2, -0.98, -0.55],
          numeratie: [-1.28, -0.71, -0.3, 0.04, 0.1]
        },
        TOUT_REFERENTIEL: {
          score_ccf: [-1.41, -0.26],
          score_syntaxe_orthographe: [-1.31, -0.08],
          score_memorisation: [-0.71, -0.31],
          score_numeratie: [-1.28, 0.1]
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
