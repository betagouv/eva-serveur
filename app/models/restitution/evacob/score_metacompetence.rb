module Restitution
  module Evacob
    class ScoreMetacompetence
      def calcule(evenements, metacompetence)
        MetriquesHelper
          .filtre_evenements_reponses(evenements) { |e| e.metacompetence?(metacompetence) }
          .sum(&:score_reponse)
      end

      def calcule_pourcentage_reussite(reponses)
        scores = reponses.map { |e| [ e["scoreMax"] || 0, e["score"] || 0 ] }
        score_max, score = scores.transpose.map(&:sum)

        Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
      end
    end
  end
end
