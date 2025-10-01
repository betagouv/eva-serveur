module Restitution
  class Securite
    class NombreDangersMalIdentifies
      def calcule(evenements_situation, _)
        evenements_situation.select(&:est_un_danger_mal_identifie?).count
      end
    end
  end
end
