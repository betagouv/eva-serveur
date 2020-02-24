# frozen_string_literal: true

module Restitution
  module Metriques
    class Base
      def initialize(evenements_situation, evenements_entrainement)
        @evenements_situation = evenements_situation
        @evenements_entrainement = evenements_entrainement
      end
    end
  end
end
