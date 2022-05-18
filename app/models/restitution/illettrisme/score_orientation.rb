# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreOrientation
      def calcule(evenements, _)
        evenements_lodi = recupere_evenements_reponses_lodi_avec_score(evenements)
        score_total = 0
        evenements_lodi.each do |reponse|
          score_total += reponse.donnees['score']
        end

        score_total
      end

      private

      def recupere_evenements_reponses_lodi_avec_score(evenements)
        evenements.select do |evenement|
          evenement.nom == MetriquesHelper::EVENEMENT[:REPONSE] &&
            evenement.donnees['question'].start_with?(MetriquesHelper::QUESTION[:LODI]) &&
            evenement.donnees['score']
        end
      end
    end
  end
end
