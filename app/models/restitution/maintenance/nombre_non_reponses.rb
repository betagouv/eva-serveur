# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreNonReponses
      attr_reader :evenements_situation

      EVENEMENT = {
        IDENTIFICATION: 'identificationMot'
      }.freeze

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.keep_if do |e|
          non_reponse?(e)
        end.count
      end

      private

      def non_reponse?(evt)
        evt.donnees['reponse'].nil? &&
          evt['nom'] == EVENEMENT[:IDENTIFICATION]
      end
    end
  end
end
