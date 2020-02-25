# frozen_string_literal: true

module Restitution
  module Metriques
    class Moyenne < Restitution::Metriques::Base
      def initialize(metrique_a_moyenner)
        @metrique_a_moyenner = metrique_a_moyenner
      end

      def calcule(evenements_situation, evenements_entrainement)
        moyenne @metrique_a_moyenner.calcule(evenements_situation, evenements_entrainement)
      end

      private

      def moyenne(liste)
        return nil if liste.empty?

        liste.sum.fdiv(liste.count).round(4)
      end
    end
  end
end
