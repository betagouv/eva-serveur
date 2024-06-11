# frozen_string_literal: true

module Restitution
  class ExportCafeDeLaPlace
    WORKSHEET_NAME = 'Données'
    SCORE_PAR_DEFAULT = 0
    ENTETES_XLS = [
      {
        titre: 'Code Question',
        taille: 20
      },
      {
        titre: 'Réponse',
        taille: 45
      },
      {
        titre: 'Score',
        taille: 10
      }
    ].freeze

    def initialize(partie:)
      @partie = partie
    end

    def to_xls
      workbook = Spreadsheet::Workbook.new
      sheet = workbook.create_worksheet(name: WORKSHEET_NAME)
      initialise_sheet(sheet)
      remplie_la_feuille(sheet)
      retourne_le_contenu_du_xls(workbook)
    end

    private

    def retourne_le_contenu_du_xls(workbook)
      file_contents = StringIO.new
      workbook.write file_contents
      file_contents.string
    end

    def remplie_la_feuille(sheet)
      ligne = 1
      evenements = Evenement.where(session_id: @partie.session_id)
      evenements.reponses.order(position: :asc).each do |evenement|
        sheet[ligne, 0] = evenement.donnees['question']
        sheet[ligne, 1] = reponse_humanisee(evenement.donnees['reponse'])
        sheet[ligne, 2] = evenement.donnees['score'] || SCORE_PAR_DEFAULT
        ligne += 1
      end
      ligne
    end

    def reponse_humanisee(reponse)
      reponse.underscore.humanize
    end

    def initialise_sheet(sheet)
      format_premiere_ligne = Spreadsheet::Format.new(weight: :bold)
      sheet.row(0).default_format = format_premiere_ligne
      ENTETES_XLS.each_with_index do |entete, colonne|
        sheet[0, colonne] = entete[:titre]
        sheet.column(colonne).width = entete[:taille]
      end
    end
  end
end
