# frozen_string_literal: true

module Restitution
  class Securite
    class NombreDangersBienIdentifiesAvantAide1
      attr_reader :evenements_situation

      def initialize(evenements)
        @evenements_situation = evenements
      end

      def calcule
        activation_aide1 = MetriquesHelper.premier_evenement_du_nom(
          evenements_situation,
          MetriquesHelper::EVENEMENT[:ACTIVATION_AIDE_1]
        )
        dangers_bien_identifies = evenements_situation.select(&:est_un_danger_bien_identifie?)
        return dangers_bien_identifies.count if activation_aide1.blank?

        dangers_bien_identifies.partition do |danger|
          danger.date < activation_aide1.date
        end.first.length
      end
    end
  end
end
