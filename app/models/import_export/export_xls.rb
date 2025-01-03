# frozen_string_literal: true

module ImportExport
  class ExportXls
    attr_reader :workbook, :sheet

    WORKSHEET = 'Données'
    WORKSHEET_SYNTHESE = 'Synthèse'

    def initialize(entetes: [], workbook: nil)
      @entetes = entetes
      @workbook = workbook
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
      @sheet.workbook.write file_contents
      file_contents.string
    end

    def create_worksheet_donnees
      ImportExport::CreationSheetXls.new(WORKSHEET, @entetes, @workbook).initialise_sheet
    end

    def create_worksheet_synthese
      ImportExport::CreationSheetXls.new(WORKSHEET_SYNTHESE, @entetes, @workbook).initialise_sheet 
    end
  end
end
