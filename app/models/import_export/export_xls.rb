# frozen_string_literal: true

module ImportExport
  class ExportXls
    attr_reader :workbook, :sheet

    WORKSHEET = 'Données'

    def initialize(entetes: [])
      @entetes = entetes
      @workbook = Spreadsheet::Workbook.new
      initialise_sheet
    end

    def content_type_xls
      'application/vnd.ms-excel'
    end

    def genere_fichier(titre)
      date = DateTime.current.strftime('%Y%m%d')
      "#{date}-#{titre}.xls"
    end

    def initialise_sheet
      @sheet = @workbook.create_worksheet(name: WORKSHEET)
      format_premiere_ligne = Spreadsheet::Format.new(weight: :bold)
      @sheet.row(0).default_format = format_premiere_ligne
      @entetes.each_with_index do |entete, colonne|
        @sheet[0, colonne] = entete[:titre]
        @sheet.column(colonne).width = entete[:taille]
      end
    end

    def retourne_le_contenu_du_xls
      file_contents = StringIO.new
      @sheet.workbook.write file_contents
      file_contents.string
    end
  end
end
