# frozen_string_literal: true

module Restitution
  module Positionnement
    class Export < ::ImportExport::ExportXls
      def initialize(partie:)
        super()
        @partie = partie
        @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
        @workbook = Spreadsheet::Workbook.new
      end

      def to_xls
        defini_onglets_du_fichier
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

      def defini_onglets_du_fichier
        if @partie.situation.numeratie?
          @sheet_synthese = cree_worksheet_synthese(
            ImportExport::Positionnement::ExportDonnees::ENTETES_SYNTHESE
          )
        end
        entetes_donnees = ImportExport::Positionnement::ExportDonnees.new(@partie).entetes
        @sheet = cree_worksheet_donnees(entetes_donnees)
      end

      def cree_worksheet_synthese(entetes)
        ::ImportExport::ExportXls.new(entetes: entetes, workbook: @workbook).cree_worksheet_synthese
      end

      def cree_worksheet_donnees(entetes)
        ::ImportExport::ExportXls.new(entetes: entetes, workbook: @workbook).cree_worksheet_donnees
      end

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
        export.regroupe_par_codes_clea.each do |code, sous_codes|
          ligne = remplis_par_sous_domaine(ligne, code, sous_codes, export)
        end
        ligne
      end

      def remplis_par_sous_domaine(ligne, code, sous_codes, export)
        reponses = sous_codes.values.flatten
        export.remplis_sous_domaine(ligne, code, reponses)
        ligne += 1
        sous_codes.each do |sous_code, evenements|
          ligne = remplis_par_sous_sous_domaine(ligne, sous_code, evenements, export)
        end
        ligne
      end

      def remplis_par_sous_sous_domaine(ligne, sous_code, evenements, export)
        export.remplis_sous_sous_domaine(ligne, sous_code, evenements)
        ligne += 1
        export.remplis_reponses(ligne, evenements)
      end
    end
  end
end
