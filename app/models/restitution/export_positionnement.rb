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

    CODECLEA_METACOMPETENCE = {
      '2.1.1' => %w[operations_addition operations_soustraction operations_multiplication
                    operations_multiplication operations_division],
      '2.1.2' => %w[denombrement],
      '2.1.3' => %w[ordonner_nombres_entiers ordonner_nombres_decimaux operations_nombres_entiers],
      '2.1.4' => %w[estimation],
      '2.3.1' => %w[unites_temps],
      '2.3.2' => %w[plannings],
      '2.3.3' => %w[renseigner_horaires],
      '2.3.5' => %w[tableaux_graphiques],
      '2.3.7' => %w[surfaces perimetres],
      '2.4.1' => %w[lecture_plan],
      '2.5.3' => %w[situation_dans_lespace reconnaitre_les_nombres reconaitre_les_nombres
                    vocabulaire_numeracie]
    }.freeze

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
      sheet.row(ligne).set_format(3, format_score(evenement.donnees['score']))
      sheet[ligne, 4] = evenement.donnees['scoreMax']
      sheet.row(ligne).set_format(4, format_score(evenement.donnees['scoreMax']))
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
      CODECLEA_METACOMPETENCE.find do |_, metacompetences|
        metacompetences.include?(metacompetence)
      end&.first
    end

    def format_score(score)
      return unless score

      if (score % 1).zero?
        Spreadsheet::Format.new(number_format: '0')
      else
        Spreadsheet::Format.new(number_format: '0.00')
      end
    end
  end
end
