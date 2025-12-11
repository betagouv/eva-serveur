module Restitution
  module Entreprises
    class PourcentageRisque
      # pourcentage => score_max
      # soit 10% pour un score <= à 8
      POURCENTAGE_RISQUE_PAR_SEUIL = {
        10 => 8,
        25 => 16,
        50 => 24,
        75 => 33
      }.freeze

      def calcule(evenements)
        evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements)

        return if evenements_reponse.blank?

        pourcentage = evenements_reponse&.sum { |e| e.donnees["score"] || 0 }

        POURCENTAGE_RISQUE_PAR_SEUIL.each do |pourcentage_risque, seuil|
          return pourcentage_risque if pourcentage <= seuil
        end
        POURCENTAGE_RISQUE_PAR_SEUIL.keys.last
      end
    end
  end
end
