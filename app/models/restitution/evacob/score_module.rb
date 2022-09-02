# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreModule
      def calcule(evenements, nom_module)
        evenements_filtres = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
          e.module?(nom_module)
        end
        evenements_filtres.sum(&:score_reponse) if evenements_filtres.present?
      end
    end
  end
end
