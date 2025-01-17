# frozen_string_literal: true

module Restitution
  module Positionnement
    class ExportLitteratie
      def initialize(partie, onglet_xls)
        super()
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id)
                                        .reponses
                                        .order(:position)
        @onglet_xls = onglet_xls
        @temps_par_question = Restitution::Metriques::TempsPasseParQuestion
                              .new(@partie.evenements).calculer
      end

      def remplis_reponses(ligne)
        @evenements_reponses.each do |evenement|
          ligne = remplis_ligne(ligne, evenement)
        end
        ligne
      end

      def remplis_ligne(ligne, evenement) # rubocop:disable Metrics/AbcSize
        @onglet_xls.set_valeur(ligne, 0, evenement.donnees['question'])
        @onglet_xls.set_valeur(ligne, 1, evenement.donnees['intitule'])
        @onglet_xls.set_valeur(ligne, 2, evenement.reponse_intitule)
        @onglet_xls.set_nombre(ligne, 3, evenement.donnees['score'])
        @onglet_xls.set_nombre(ligne, 4, evenement.donnees['scoreMax'])
        @onglet_xls.set_valeur(ligne, 5, evenement.donnees['metacompetence'])
        @onglet_xls.set_valeur(ligne, 6, @temps_par_question[evenement.donnees['question']])
        ligne + 1
      end
    end
  end
end
