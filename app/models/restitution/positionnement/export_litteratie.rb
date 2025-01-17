# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportLitteratie
      def initialize(partie, sheet)
        super()
        @sheet = sheet
        @partie = partie
        @temps_par_question = Restitution::Metriques::TempsPasseParQuestion
                              .new(@partie.evenements).calculer
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
      end

      def remplis_reponses(ligne)
        @evenements_reponses.sort_by(&:position).each do |evenement|
          ligne = remplis_ligne(ligne, evenement)
        end
        ligne
      end

      def remplis_ligne(ligne, evenement)
        @sheet.row(ligne).replace([evenement.donnees['question'],
                                   evenement.donnees['intitule'],
                                   evenement.reponse_intitule,
                                   evenement.donnees['score'],
                                   evenement.donnees['scoreMax'],
                                   evenement.donnees['metacompetence'],
                                   @temps_par_question[evenement.donnees['question']]])
        ligne + 1
      end
    end
  end
end
