# frozen_string_literal: true

module Restitution
  class Base
    class TempsTotal < Restitution::Metriques::Base
      def calcule
        evenements = @evenements_entrainement + @evenements_situation
        return nil if evenements.empty?

        evenements.last.date - evenements.first.date
      end
    end
  end
end
