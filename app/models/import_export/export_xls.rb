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

    def cree_worksheet_donnees
      onglet = ImportExport::Worksheet.new(WORKSHEET, @workbook)
      onglet.remplis_entetes(@entetes)
      onglet.sheet
    end

    def cree_worksheet_synthese
      onglet = ImportExport::Worksheet.new(WORKSHEET_SYNTHESE, @workbook)
      onglet.remplis_entetes(@entetes)
      onglet.sheet
    end
  end
end
