# frozen_string_literal: true

module Restitution
  module Positionnement
    class Export < ::ImportExport::ExportXls
      def initialize(partie:)
        super()
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
      end

      def to_xls
        entetes = ImportExport::Positionnement::ExportDonnees.new(@partie).entetes
        @sheet = ::ImportExport::ExportXls.new(entetes: entetes).sheet
        remplie_la_feuille
        retourne_le_contenu_du_xls
      end

      def nom_du_fichier
        evaluation = @partie.evaluation
        code_de_campagne = evaluation.campagne.code.parameterize
        nom_de_levaluation = evaluation.nom.parameterize.first(15)
        genere_fichier("#{nom_de_levaluation}-#{code_de_campagne}")
      end

      private

      def remplie_la_feuille
        ligne = 1
        if @partie.situation.litteratie?
          ligne = remplis_reponses_litteratie(ligne)
        elsif @partie.situation.numeratie?
          ligne = remplis_reponses_numeratie(ligne)
        end
        ligne
      end

      def remplis_reponses_litteratie(ligne)
        export = ExportLitteratie.new(@evenements_reponses.sort_by(&:position), @sheet)
        export.remplis_reponses(ligne)
      end

      def remplis_reponses_numeratie(ligne)
        export = ExportNumeratie.new(@partie, @sheet)
        export.regroupe_par_code_clea.each do |code, evenements|
          ligne = export.remplis_reponses_par_code(ligne, evenements, code)
        end
        ligne
      end
    end
  end
end
