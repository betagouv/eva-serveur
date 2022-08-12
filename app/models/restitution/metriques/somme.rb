# frozen_string_literal: true

module Restitution
  module Metriques
    class Somme
      def initialize(metriques_a_additionner)
        @metriques_a_additionner = metriques_a_additionner
      end

      def calcule(premier_parametre, deuxieme_parametre)
        somme @metriques_a_additionner.calcule(premier_parametre, deuxieme_parametre)
      end

      private

      def somme(liste)
        liste.sum if liste.present?
      end
    end
  end
end
