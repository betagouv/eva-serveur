# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenNonMots
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        Restitution::MetriquesHelper.temps_action_moyen(evenements_situation,
                                                        :identification_non_mot_correct,
                                                        &:type_non_mot)
      end
    end
  end
end
