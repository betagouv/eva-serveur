module Restitution
  module Metriques
    class Moyenne
      def initialize(metrique_a_moyenner)
        @metrique_a_moyenner = metrique_a_moyenner
      end

      def calcule(premier_parametre, deuxieme_parametre)
        moyenne @metrique_a_moyenner.calcule(premier_parametre, deuxieme_parametre)
      end

      private

      def moyenne(liste)
        return nil if liste.empty?

        liste.sum.fdiv(liste.count)
      end
    end
  end
end
