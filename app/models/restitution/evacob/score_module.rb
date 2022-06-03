# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreModule
      def calcule(evenements, nom_module)
        MetriquesHelper.filtre_evenements_reponses(evenements) { |e| e.module?(nom_module) }
                       .sum(&:score_reponse)
      end
    end
  end
end
