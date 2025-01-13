# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportLitteratie
      def initialize(evenements_reponses, sheet)
        super()
        @evenements_reponses = evenements_reponses
        @sheet = sheet
      end

      def remplis_reponses(ligne)
        @evenements_reponses.each do |evenement|
          ligne = remplis_ligne(ligne, evenement)
        end
        ligne
      end

      def remplis_ligne(ligne, evenement)
        @sheet.row(ligne).replace([evenement.donnees['question'],
                                   evenement.donnees['intitule'],
                                   evenement.reponse_intitule,
                                   calcule_temps_passe(evenement),
                                   evenement.donnees['score'],
                                   evenement.donnees['scoreMax'],
                                   evenement.donnees['metacompetence']])
        ligne + 1
      end

      def calcule_temps_passe(evenement)
        evenement_debut = evenement.recupere_evenement_affichage_question_qcm
        temps_total = evenement_debut.nil? ? 0 : evenement.date - evenement_debut.date

        Restitution::Base::TempsTotal.format_temps_total(temps_total)
      end
    end
  end
end
