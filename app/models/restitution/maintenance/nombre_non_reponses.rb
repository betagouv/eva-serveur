module Restitution
  class Maintenance
    class NombreNonReponses
      def calcule(evenements_situation, _)
        evenements_situation.select(&:non_reponse?).count
      end
    end
  end
end
