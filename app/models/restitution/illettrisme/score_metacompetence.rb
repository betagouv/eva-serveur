module Restitution
  module Illettrisme
    class ScoreMetacompetence
      def calcule(evenements, metacompetence)
        nombre_bonnes_reponses = nombre_bonnes_reponses(evenements, metacompetence)
        return 0 if nombre_bonnes_reponses.zero?

        temps_moyen = temps_moyen_bonnes_reponses(evenements, metacompetence)
        return if temps_moyen.nil? || temps_moyen.zero?

        nombre_bonnes_reponses.fdiv(temps_moyen)
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
