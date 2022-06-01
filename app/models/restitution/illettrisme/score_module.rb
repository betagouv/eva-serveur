# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreModule
      def calcule(evenements, nom_module)
        evenements_reponses_module(evenements, nom_module).sum(&:score_reponse)
      end

      private

      def evenements_reponses_module(evenements, nom_module)
        evenements.select do |evenement|
          evenement.nom == MetriquesHelper::EVENEMENT[:REPONSE] &&
            evenement.module?(nom_module)
        end
      end
    end
  end
end
