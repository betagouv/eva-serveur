module ImportExport
  class ExportXls
    NOMBRE_MAX_LIGNES = 3000

    attr_reader :workbook, :export, :onglets

    WORKSHEET_DONNEES = "Données"
    WORKSHEET_SYNTHESE = "Synthèse"

    def initialize
      @workbook = Spreadsheet::Workbook.new
      @onglets = {}
      @donnees = []
    end

    def to_xls
      entetes = @headers.map { |header| { titre: header.to_s.humanize, taille: 20 } }
      @export = ::ImportExport::ExportXls.new
      @onglet = @export.cree_worksheet_donnees(entetes)

      remplis_la_feuille
      retourne_le_contenu_du_xls
    end

    def nom_du_fichier(type)
      nom_fichier_horodate(type, "xls")
    end

    def content_type_xls
      "application/vnd.ms-excel"
    end

    def retourne_le_contenu_du_xls
      file_contents = StringIO.new
      @export.workbook.write file_contents
      file_contents.string
    end

    def cree_worksheet_donnees(entetes)
      @onglets[WORKSHEET_DONNEES.to_sym] = OngletXls.new(WORKSHEET_DONNEES, @workbook, entetes)
    end

    def cree_worksheet_synthese(entetes)
      @onglets[WORKSHEET_SYNTHESE.to_sym] = OngletXls.new(WORKSHEET_SYNTHESE, @workbook, entetes)
    end

    def remplis_la_feuille
      @donnees.each_with_index do |donnee, index|
        @ligne = index + 1
        remplis_champs(donnee)
      end
    end
  end
end
