# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreErreurs
      attr_reader :evenements_situation

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.select do |e|
          mauvaises_reponses(e)
        end.count
      end

      private

      def mauvaises_reponses(evt)
        mot_pas_francais_reponse_francais?(evt) ||
          mot_francais_reponse_non_francais?(evt)
      end

      def mot_pas_francais_reponse_francais?(evt)
        evt.type_non_mot &&
          evt.reponse_francais
      end

      def mot_francais_reponse_non_francais?(evt)
        evt.type_mot_francais &&
          evt.reponse_non_francais
      end
    end
  end
end
