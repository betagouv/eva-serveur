module Restitution
  module Metriques
    class MapToList
      def initialize(metrique_a_moyenner)
        @metrique_a_moyenner = metrique_a_moyenner
      end

      def calcule(premier_parametre, deuxieme_parametre)
        @metrique_a_moyenner.calcule(premier_parametre, deuxieme_parametre).values
      end
    end
  end
end
