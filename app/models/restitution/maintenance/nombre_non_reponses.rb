# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreNonReponses
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select do |e|
          non_reponse?(e)
        end.count
      end

      private

      def non_reponse?(evt)
        evt.donnees['reponse'].nil? &&
          evt.identification_mot
      end
    end
  end
end
