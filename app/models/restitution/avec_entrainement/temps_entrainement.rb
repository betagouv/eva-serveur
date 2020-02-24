# frozen_string_literal: true

module Restitution
  class AvecEntrainement
    class TempsEntrainement
      def initialize(_, evenements_entrainement)
        @evenements_entrainement = evenements_entrainement
      end

      def calcule
        return nil if @evenements_entrainement.empty?

        @evenements_entrainement.last.date - @evenements_entrainement.first.date
      end
    end
  end
end
