module Restitution
  class Securite
    class NombreDangersBienIdentifies
      def calcule(evenements_situation, _)
        evenements_situation.select(&:est_un_danger_bien_identifie?).count
      end
    end
  end
end
