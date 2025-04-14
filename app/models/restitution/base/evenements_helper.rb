# frozen_string_literal: true

module Restitution
  class Base
    class EvenementsHelper
      EVENEMENT = {
        FIN_SITUATION: "finSituation",
        REJOUE_CONSIGNE: "rejoueConsigne",
        ABANDON: "abandon"
      }.freeze

      def initialize(evenements)
        @evenements = evenements
      end

      def partie
        @partie ||= Partie.find_by(session_id: premier_evenement.session_id)
      end

      def compte_nom_evenements(nom)
        @evenements.count { |e| e.nom == nom }
      end

      # Deprecated: utiliser la règle Base::TempsTotal à la place
      def temps_total
        dernier_evenement.date - premier_evenement.date
      end

      def nombre_rejoue_consigne
        compte_nom_evenements EVENEMENT[:REJOUE_CONSIGNE]
      end

      def abandon?
        dernier_evenement.nom == EVENEMENT[:ABANDON]
      end

      def termine?
        dernier_evenement.nom == EVENEMENT[:FIN_SITUATION]
      end

      def premier_evenement
        @premier_evenement ||= @evenements.first
      end

      def dernier_evenement
        @dernier_evenement ||= @evenements.last
      end
    end
  end
end
