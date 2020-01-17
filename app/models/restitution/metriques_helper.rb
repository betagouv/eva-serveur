# frozen_string_literal: true

module Restitution
  class MetriquesHelper
    class << self
      def temps_entre_couples(evenements)
        les_temps = []
        evenements.each_slice(2) do |e1, e2|
          next if e2.blank?

          les_temps << e2.date - e1.date
        end
        les_temps
      end
    end
  end
end
