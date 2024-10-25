# frozen_string_literal: true

module Restitution
  class ExportPositionnement
    WORKSHEET_NAME = 'Données'

    ENTETES_XLS = [
      { titre: 'Code Question', taille: 20 },
      { titre: 'Intitulé', taille: 80 },
      { titre: 'Réponse', taille: 45 },
      { titre: 'Score', taille: 10 },
      { titre: 'Score max', taille: 10 },
      { titre: 'Métacompétence', taille: 20 },
      { titre: 'Code cléa', taille: 20 }
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

    def content_type_xls
      'application/vnd.ms-excel'
    end

    def nom_du_fichier
      evaluation = @partie.evaluation

      code_de_campagne = evaluation.campagne.code.parameterize
      nom_de_levaluation = evaluation.nom.parameterize.first(15)
      date = DateTime.current.strftime('%Y%m%d')
      "#{date}-#{nom_de_levaluation}-#{code_de_campagne}.xls"
    end

    def regroupe_par_code_clea(evenements)
      evenements.group_by do |evenement|
        code = code_clea(evenement)
        [code.nil? ? 1 : 0, code]
      end
    end

    private

    def retourne_le_contenu_du_xls(workbook)
      file_contents = StringIO.new
      workbook.write file_contents
      file_contents.string
    end

    def remplie_la_feuille(sheet)
      ligne = 1
      evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
      regroupe_par_code_clea(evenements_reponses).each do |code, evenements|
        ligne = remplis_reponses_par_code(sheet, ligne, code, evenements)
      end
      ligne
    end

    def remplis_reponses_par_code(sheet, ligne, code, evenements)
      if code[1].present?
        sheet[ligne, 0] = "#{code[1]} - score: #{pourcentage_reussite(evenements)}%"
        sheet.merge_cells(ligne, 0, ligne, 6)
      end
      ligne += 1
      remplis_reponses(sheet, ligne, evenements)
    end

    def pourcentage_reussite(evenements)
      scores = evenements.map { |e| [e.donnees['scoreMax'], e.donnees['score']] }
      score_max, score = scores.transpose.map(&:sum)
      score_max.zero? ? 0 : (score * 100 / score_max).round
    end

    def remplis_reponses(sheet, ligne, evenements)
      evenements.sort_by(&:position).each do |evenement|
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
      sheet[ligne, 6] = code_clea(evenement)

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

    def code_clea(evenement)
      metacompetence = evenement.donnees['metacompetence']
      Evenement::CODECLEA_METACOMPETENCE.find do |_, metacompetences|
        metacompetences.include?(metacompetence)
      end&.first
    end
  end
end
