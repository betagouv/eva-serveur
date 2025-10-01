module Restitution
  class Maintenance
    class NombreBonnesReponsesNonMot
      def calcule(evenements_situation, _)
        evenements_situation.select(&:identification_non_mot_correct?).count
      end
    end
  end
end
