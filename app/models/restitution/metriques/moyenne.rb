# frozen_string_literal: true

module Restitution
  module Metriques
    class Moyenne < Restitution::Metriques::Base
      def calcule
        moyenne classe_metrique.new(@evenements_situation, @evenements_entrainement)
                               .calcule
      end

      private

      def moyenne(liste)
        return nil if liste.empty?

        liste.sum.fdiv(liste.count).round(4)
      end
    end
  end
end
