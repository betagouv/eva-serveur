module Restitution
  module Metriques
    class TempsNormalises
      def initialize(metriques_temps, moyenne, ecart_type)
        @metriques_temps = metriques_temps
        @moyenne = moyenne
        @ecart_type = ecart_type
      end

      def calcule(evenements_situation, evenements_entrainement)
        les_temps = @metriques_temps.calcule(evenements_situation, evenements_entrainement)

        bornes = [ @moyenne - (2 * @ecart_type), @moyenne + (2 * @ecart_type) ]

        les_temps.select do |temps|
          temps.between?(bornes.first, bornes.last)
        end
      end
    end
  end
end
