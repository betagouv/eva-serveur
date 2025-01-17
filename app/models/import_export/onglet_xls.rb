# frozen_string_literal: true

module ImportExport
  class OngletXls
    attr_reader :sheet

    def initialize(titre, workbook, entetes)
      @titre = titre
      @workbook = workbook

      @sheet = @workbook.create_worksheet(name: @titre)
      format_premiere_ligne = Spreadsheet::Format.new(weight: :bold, border: :none)
      @sheet.row(0).default_format = format_premiere_ligne
      remplis_entetes(entetes)
    end

    def set_valeur(ligne, colonne, valeur)
      @sheet.row(ligne)[colonne] = valeur
    end

    def set_nombre(ligne, colonne, valeur)
      set_valeur(ligne, colonne, valeur)
      @sheet.row(ligne).set_format(colonne, ExportXls::NUMBER_FORMAT)
    end

    def set_pourcentage(ligne, colonne, valeur)
      set_valeur(ligne, colonne, valeur)
      @sheet.row(ligne).set_format(colonne, ExportXls::POURCENTAGE_FORMAT)
    end

    XLS_COLOR_GRAY = :xls_color_14 # rubocop:disable Naming/VariableNumber
    def grise_ligne(ligne)
      format_grise = Spreadsheet::Format.new(pattern_fg_color: XLS_COLOR_GRAY, pattern: 1)
      @sheet.row(ligne).default_format = format_grise
    end

    private

    def remplis_entetes(entetes)
      entetes.each_with_index do |entete, colonne|
        @sheet[0, colonne] = entete[:titre]
        @sheet.column(colonne).width = entete[:taille]
      end
    end
  end
end
