# frozen_string_literal: true

module Restitution
  module Positionnement
    class Export < ::ImportExport::ExportXls
      include Fichier

      def initialize(partie:)
        super()
        @partie = partie
        @export = ::ImportExport::ExportXls.new
      end

      def to_xls
        defini_onglets_du_fichier
        remplie_les_onglets
        retourne_le_contenu_du_xls
      end

      def nom_du_fichier
        evaluation = @partie.evaluation
        code_de_campagne = evaluation.campagne.code.parameterize
        nom_de_levaluation = evaluation.nom.parameterize.first(15)
        nom_fichier_horodate("#{nom_de_levaluation}-#{code_de_campagne}", 'xls')
      end

      private

      def defini_onglets_du_fichier
        if @partie.situation.numeratie?
          @onglet_synthese = @export.cree_worksheet_synthese(
            ImportExport::Positionnement::ExportDonnees::ENTETES_SYNTHESE
          )
        end
        entetes_donnees = ImportExport::Positionnement::ExportDonnees.new(@partie).entetes
        @onglet_donnees = @export.cree_worksheet_donnees(entetes_donnees)
      end

      def remplie_les_onglets
        if @partie.situation.litteratie?
          ExportLitteratie.new(@partie, @onglet_donnees).remplis_reponses(1)
        elsif @partie.situation.numeratie?
          ExportNumeratie.new(@partie, @onglet_donnees).remplis_reponses(1)
          remplie_la_feuille_de_synthese
        end
      end

      def remplie_la_feuille_de_synthese
        ligne = 1
        export = ExportNumeratie.new(@partie, @onglet_synthese)
        ligne = defini_le_tableau_des_sous_domaines(ligne, export)
        ligne += 1
        ajoute_en_tetes(@onglet_synthese.sheet, ligne,
                        ImportExport::Positionnement::ExportDonnees::ENTETES_SYNTHESE)
        ligne += 1
        defini_le_tableau_des_sous_sous_domaines(ligne, export)
      end

      def defini_le_tableau_des_sous_domaines(ligne, export)
        export.regroupe_par_codes_clea.each do |code, sous_codes|
          ligne = remplis_par_sous_domaine_sythese(ligne, code, sous_codes, export)
        end

        ligne
      end

      def defini_le_tableau_des_sous_sous_domaines(ligne, export)
        export.regroupe_par_codes_clea.each_value do |sous_codes|
          ligne = remplis_sous_sous_domaine_synthese(ligne, sous_codes, export)
        end

        ligne
      end

      def remplis_par_sous_domaine_sythese(ligne, code, sous_codes, export)
        evenements_questions = sous_codes.values.flatten
        export.remplis_sous_domaine(ligne, code, evenements_questions)
        ligne + 1
      end

      def remplis_sous_sous_domaine_synthese(ligne, sous_codes, export)
        sous_codes.each do |sous_code, evenements_questions|
          ligne = recupere_les_sous_sous_domaines(ligne, sous_code, evenements_questions, export)
        end

        ligne
      end

      def recupere_les_sous_sous_domaines(ligne, sous_code, evenements_questions, export)
        export.remplis_sous_sous_domaine(ligne, sous_code, evenements_questions)
        ligne + 1
      end

      def ajoute_en_tetes(sheet, ligne_depart, entetes)
        format_entetes = Spreadsheet::Format.new(
          weight: :bold
        )

        entetes.each_with_index do |entete, colonne|
          sheet[ligne_depart, colonne] = entete[:titre]
          sheet.row(ligne_depart).set_format(colonne, format_entetes)
        end
      end
    end
  end
end
