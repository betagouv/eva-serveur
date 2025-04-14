# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurScores
      PALIERS = {
        CEFR: {
          litteratie: [ -3.55, -1.33, -0.4 ],
          numeratie: [ -1.64, -1, 0 ]
        },
        ANLCI: {
          litteratie: [ -4.1, -3.18, -2.25, -1.33, -0.4 ],
          numeratie: [ -1.68, -1, -0.33, 0.35, 1.02 ]
        },
        TOUT_REFERENTIEL: {
          score_ccf: [ -1, 0 ],
          score_syntaxe_orthographe: [ -1, 0 ],
          score_memorisation: [ -1, 0 ],
          score_numeratie: [ -1, 0 ]
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
          return :"palier#{index}" if score <= palier
        end

        :"palier#{PALIERS[referentiel][competence].count}"
      end
    end
  end
end
