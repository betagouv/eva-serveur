# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreBonnesReponsesMotFrancais
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select(&:identification_mot_francais_correct).count
      end
    end
  end
end
