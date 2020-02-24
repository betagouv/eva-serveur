# frozen_string_literal: true

module Restitution
  class AvecEntrainement
    class TempsEntrainement < Restitution::Metriques::Base
      def calcule
        return nil if @evenements_entrainement.empty?

        @evenements_entrainement.last.date - @evenements_entrainement.first.date
      end
    end
  end
end
