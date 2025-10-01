module Restitution
  class Securite
    class AttentionVisuoSpaciale
      def calcule(evenements_situation, _)
        identification = evenements_situation
                         .select(&:est_un_danger_bien_identifie?)
                         .find(&:danger_visuo_spatial?)
        return ::Competence::NIVEAU_INDETERMINE if identification.blank?

        activation_aide1 = MetriquesHelper.activation_aide1(evenements_situation)
        if activation_aide1.present? && activation_aide1.date < identification.date
          return ::Competence::APTE_AVEC_AIDE
        end

        ::Competence::APTE
      end
    end
  end
end
