module Restitution
  class AvecEntrainement
    class TempsEntrainement
      def calcule(_, evenements_entrainement)
        return nil if evenements_entrainement.empty?

        evenements_entrainement.last.date - evenements_entrainement.first.date
      end
    end
  end
end
