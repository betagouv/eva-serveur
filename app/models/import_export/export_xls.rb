# frozen_string_literal: true

module ImportExport
  class ExportXls
    attr_reader :workbook, :export, :onglets

    WORKSHEET_DONNEES = 'Données'
    WORKSHEET_SYNTHESE = 'Synthèse'
    NUMBER_FORMAT = Spreadsheet::Format.new(number_format: '0')
    POURCENTAGE_FORMAT = Spreadsheet::Format.new(number_format: '0%')

    def initialize
      @workbook = Spreadsheet::Workbook.new
      @onglets = {}
    end

    def content_type_xls
      'application/vnd.ms-excel'
    end

    def genere_fichier(titre)
      date = DateTime.current.strftime('%Y%m%d')
      "#{date}-#{titre}.xls"
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
  end
end
