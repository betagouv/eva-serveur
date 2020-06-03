# frozen_string_literal: true

module Restitution
  module Illettrisme
    class ScoreMetacompetence < Restitution::Metriques::Base
      def calcule(evenements, metacompetence)
        temps_moyen = temps_moyen_bonnes_reponses(evenements, metacompetence)
        return if temps_moyen.nil? || temps_moyen.zero?

        nombre_bonnes_reponses(evenements, metacompetence).fdiv(temps_moyen)
      end

      private

      def nombre_bonnes_reponses(evenements, metacompetence)
        Illettrisme::NombreBonnesReponses.new.calcule(evenements, metacompetence)
      end

      def temps_moyen_bonnes_reponses(evenements, metacompetence)
        metrique = Illettrisme::TempsBonnesReponses.new
        Metriques::Moyenne.new(metrique).calcule(evenements, metacompetence)
      end
    end
  end
end
