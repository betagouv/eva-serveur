# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreErreurs
      attr_reader :evenements_situation

      EVENEMENT = {
        NOM_MOT: 'non-mot',
        REPONSE_NON_FRANCAIS: 'pasfrancais',
        REPONSE_FRANCAIS: 'francais'
      }.freeze

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        evenements_situation.keep_if do |e|
          mauvaises_reponses(e)
        end.count
      end

      private

      def mauvaises_reponses(evt)
        mot_pas_francais_reponse_francais?(evt) ||
          mot_francais_reponse_non_francais?(evt)
      end

      def mot_pas_francais_reponse_francais?(evt)
        (evt.donnees['type'] == EVENEMENT[:NOM_MOT]) &&
          (evt.donnees['reponse'] == EVENEMENT[:REPONSE_FRANCAIS])
      end

      def mot_francais_reponse_non_francais?(evt)
        (evt.donnees['type'] != EVENEMENT[:NOM_MOT]) &&
          (evt.donnees['reponse'] == EVENEMENT[:REPONSE_NON_FRANCAIS])
      end
    end
  end
end
