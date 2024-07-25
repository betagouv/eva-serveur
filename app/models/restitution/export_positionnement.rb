# frozen_string_literal: true

module Restitution
  class ExportPositionnement
    WORKSHEET_NAME = 'Données'
    ENTETES_XLS = [
      {
        titre: 'Code Question',
        taille: 20
      },
      {
        titre: 'Intitulé',
        taille: 80
      },
      {
        titre: 'Réponse',
        taille: 45
      },
      {
        titre: 'Score',
        taille: 10
      },
      {
        titre: 'Score max',
        taille: 10
      },
      {
        titre: 'Métacompétence',
        taille: 20
      }
    ].freeze

    def initialize(partie_litteratie:, partie_numeratie:)
      @partie_litteratie = partie_litteratie
      @partie_numeratie = partie_numeratie
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
      evenements = Evenement.where(session_id: @partie_litteratie&.session_id)
                            .or(Evenement.where(session_id: @partie_numeratie&.session_id))
      evenements.reponses.order(position: :asc).each do |evenement|
        sheet = remplis_la_ligne(sheet, ligne, evenement)
        ligne += 1
      end
      ligne
    end

    # rubocop:disable Metrics/AbcSize
    def remplis_la_ligne(sheet, ligne, evenement)
      sheet[ligne, 0] = evenement.donnees['question']
      sheet[ligne, 1] = evenement.donnees['intitule']
      sheet[ligne, 2] = evenement.reponse_intitule
      sheet[ligne, 3] = evenement.donnees['score']
      sheet[ligne, 4] = evenement.donnees['scoreMax']
      sheet[ligne, 5] = evenement.donnees['metacompetence']

      sheet
    end
    # rubocop:enable Metrics/AbcSize

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
