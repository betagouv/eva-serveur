# frozen_string_literal: true

module ImportExport
  class OngletXls
    attr_reader :sheet

    NUMBER_FORMAT = '0'
    DECIMAL_NUMBER_FORMAT = '0.0#'
    POURCENTAGE_FORMAT = '0%'

    def initialize(titre, workbook, entetes)
      @titre = titre
      @workbook = workbook

      @sheet = @workbook.create_worksheet(name: @titre)
      format_premiere_ligne = Spreadsheet::Format.new(weight: :bold, border: :none)
      set_format_ligne(0, format_premiere_ligne)
      remplis_entetes(entetes)
    end

    def set_valeur(ligne, colonne, valeur)
      @sheet.row(ligne)[colonne] = valeur
    end

    def set_nombre(ligne, colonne, valeur)
      return if valeur.nil?

      set_valeur(ligne, colonne, valeur)
      format = nombre_est_un_entier?(valeur) ? NUMBER_FORMAT : DECIMAL_NUMBER_FORMAT
      set_format_colonne(ligne, colonne, format)
    end

    def set_pourcentage(ligne, colonne, valeur)
      set_valeur(ligne, colonne, valeur)
      set_format_colonne(ligne, colonne, POURCENTAGE_FORMAT)
    end

    XLS_COLOR_GRAY = :xls_color_14 # rubocop:disable Naming/VariableNumber
    def grise_ligne(ligne)
      format_grise = Spreadsheet::Format.new(pattern_fg_color: XLS_COLOR_GRAY, pattern: 1)
      set_format_ligne(ligne, format_grise)
    end

    private

    def remplis_entetes(entetes)
      entetes.each_with_index do |entete, colonne|
        @sheet[0, colonne] = entete[:titre]
        @sheet.column(colonne).width = entete[:taille]
      end
    end

    def set_format_colonne(ligne, colonne, number_format)
      ancien_format = @sheet.row(ligne).format(colonne)
      nouveau_format = Spreadsheet::Format.new(
        number_format: number_format,
        pattern: ancien_format.pattern,
        pattern_fg_color: ancien_format.pattern_fg_color
      )
      @sheet.row(ligne).set_format(colonne, nouveau_format)
    end

    def set_format_ligne(ligne, number_format)
      @sheet.row(ligne).default_format = number_format
    end

    def nombre_est_un_entier?(nombre)
      (nombre % 1).zero?
    end
  end
end
