# frozen_string_literal: true

module ImportExport
  class Worksheet
    attr_reader :sheet

    def initialize(titre, workbook)
      @titre = titre
      @workbook = workbook

      @sheet = @workbook.create_worksheet(name: @titre)
      format_premiere_ligne = Spreadsheet::Format.new(weight: :bold)
      @sheet.row(0).default_format = format_premiere_ligne
    end

    def remplis_entetes(entetes)
      entetes.each_with_index do |entete, colonne|
        @sheet[0, colonne] = entete[:titre]
        @sheet.column(colonne).width = entete[:taille]
      end
    end
  end
end
