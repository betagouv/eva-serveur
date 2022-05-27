# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreOrientation
      def calcule(evenements, _)
        evenements_reponses_lodi_avec_score(evenements).sum(&:score_reponse)
      end

      private

      def evenements_reponses_lodi_avec_score(evenements)
        evenements.select do |evenement|
          evenement.nom == MetriquesHelper::EVENEMENT[:REPONSE] &&
            evenement.parcours?(:orientation) &&
            evenement.score_reponse
        end
      end
    end
  end
end
