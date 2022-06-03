# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreMetacompetence
      def calcule(evenements, metacompetence)
        MetriquesHelper
          .filtre_evenements_reponses(evenements) { |e| e.metacompetence?(metacompetence) }
          .sum(&:score_reponse)
      end
    end
  end
end
