# frozen_string_literal: true

module Restitution
  class Base
    class TempsTotal
      def calcule(evenements_situation, evenements_entrainement)
        evenements = evenements_entrainement + evenements_situation
        return nil if evenements.empty?

        evenements.last.date - evenements.first.date
      end

      def self.format_temps_total(temps_total)
        minutes = temps_total / 60
        seconds = temps_total % 60
        format('%<minutes>02d:%<seconds>02d', minutes: minutes, seconds: seconds)
      end
    end
  end
end
