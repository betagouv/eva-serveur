# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreMetacompetence < Restitution::Metriques::Base
      def calcule(evenements, metacompetence)
        return if temps_moyen_bonnes_reponses(evenements, metacompetence).nil? ||
                  temps_moyen_bonnes_reponses(evenements, metacompetence).zero?

        nombre_bonnes_reponses(evenements, metacompetence)
          .fdiv(temps_moyen_bonnes_reponses(evenements, metacompetence))
      end

      private

      def nombre_bonnes_reponses(evenements, metacompetence)
        metrique = Illettrisme::NombreBonnesReponses.new
        @nombre_bonnes_reponses ||= metrique.calcule(evenements, metacompetence)
      end

      def temps_moyen_bonnes_reponses(evenements, metacompetence)
        metrique = Illettrisme::TempsBonnesReponses.new
        @temps_moyen_bonnes_reponses ||= Metriques::Moyenne.new(metrique)
                                                           .calcule(evenements, metacompetence)
      end
    end
  end
end
