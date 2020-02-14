# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreBonnesReponsesMotFrancais
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select do |e|
          e.type_mot_francais &&
            e.reponse_francais
        end.count
      end
    end
  end
end
