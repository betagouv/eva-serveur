# frozen_string_literal: true

module Restitution
  class Base
    class TempsTotal
      def calcule(evenements_situation, evenements_entrainement)
        evenements = evenements_entrainement + evenements_situation
        return nil if evenements.empty?

        evenements.last.date - evenements.first.date
      end
    end
  end
end
