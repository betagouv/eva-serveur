# frozen_string_literal: true

module Restitution
  class Base
    class EvenementsHelper
      EVENEMENT = {
        FIN_SITUATION: 'finSituation',
        REJOUE_CONSIGNE: 'rejoueConsigne',
        ABANDON: 'abandon'
      }.freeze

      def initialize(evenements)
        @evenements = evenements
      end

      def partie
        @partie ||= premier.partie
      end

      def compte_nom_evenements(nom)
        @evenements.count { |e| e.nom == nom }
      end

      # Deprecated: utiliser la règle Base::TempsTotal à la place
      def temps_total
        dernier.date - premier.date
      end

      def nombre_rejoue_consigne
        compte_nom_evenements EVENEMENT[:REJOUE_CONSIGNE]
      end

      def abandon?
        dernier.nom == EVENEMENT[:ABANDON]
      end

      def termine?
        dernier.nom == EVENEMENT[:FIN_SITUATION]
      end

      private

      def premier
        @premier ||= @evenements.first
      end

      def dernier
        @dernier ||= @evenements.last
      end
    end
  end
end
