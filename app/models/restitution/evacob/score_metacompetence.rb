# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreMetacompetence
      def calcule(evenements, metacompetence)
        MetriquesHelper
          .filtre_evenements_reponses(evenements) { |e| e.metacompetence?(metacompetence) }
          .sum(&:score_reponse)
      end

      def calcule_pourcentage_reussite(reponses)
        scores = reponses.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
        score_max, score = scores.transpose.map(&:sum)
        score_max.zero? ? nil : (score.to_f * 100 / score_max.to_f).round
      end
    end
  end
end
