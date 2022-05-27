# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreOrientation
      def calcule(evenements, _)
        evenements_reponses_lodi(evenements).sum(&:score_reponse)
      end

      private

      def evenements_reponses_lodi(evenements)
        evenements.select do |evenement|
          evenement.nom == MetriquesHelper::EVENEMENT[:REPONSE] &&
            evenement.parcours?(:orientation)
        end
      end
    end
  end
end
