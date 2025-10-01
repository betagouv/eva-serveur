module Restitution
  class Securite
    class NombreDangersBienIdentifiesAvantAide1
      def calcule(evenements_situation, _)
        activation_aide1 = MetriquesHelper.activation_aide1(evenements_situation)
        dangers_bien_identifies = evenements_situation.select(&:est_un_danger_bien_identifie?)
        return dangers_bien_identifies.count if activation_aide1.blank?

        dangers_bien_identifies.partition do |danger|
          danger.date < activation_aide1.date
        end.first.length
      end
    end
  end
end
