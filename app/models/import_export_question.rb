# frozen_string_literal: true

class ImportExportQuestion
  HEADERS_CLIC_DANS_IMAGE = %i[zone_cliquable image_au_clic].freeze
  HEADERS_GLISSER_DEPOSER = %i[zone_depot].freeze
  HEADERS_QCM = %i[type_qcm].freeze
  HEADERS_SAISIE = %i[suffix_reponse reponse_placeholder type_saisie bonne_reponse_intitule
                      bonne_reponse_nom_technique].freeze
  HEADERS_SOUS_CONSIGNE = %i[libelle nom_technique illustration intitule_ecrit
                             intitule_audio].freeze
  HEADERS_COMMUN = %i[libelle nom_technique illustration intitule_ecrit intitule_audio
                      consigne_ecrit consigne_audio description].freeze
  HEADERS_ATTENDUS = { 'QuestionClicDansImage' => HEADERS_COMMUN + HEADERS_CLIC_DANS_IMAGE,
                       'QuestionGlisserDeposer' => HEADERS_COMMUN + HEADERS_GLISSER_DEPOSER,
                       'QuestionQcm' => HEADERS_COMMUN + HEADERS_QCM,
                       'QuestionSaisie' => HEADERS_COMMUN + HEADERS_SAISIE,
                       'QuestionSousConsigne' => HEADERS_SOUS_CONSIGNE }.freeze

  delegate :message_erreur_headers, to: :@import

  def initialize(question)
    @question = question
    @type = question.type
    @import = ImportQuestion.new(@question, HEADERS_ATTENDUS[@type])
  end

  def importe_donnees(file)
    @import.recupere_data(file)
    @import.valide_headers
    @import.cree_question
  rescue ActiveRecord::RecordInvalid => e
    raise Error, message_erreur_validation(e)
  end

  def exporte_donnees
    send_data to_xls,
              content_type: content_type_xls,
              filename: nom_du_fichier
  end

  # def to_xls
  #   workbook = Spreadsheet::Workbook.new
  #   sheet = workbook.create_worksheet(name: 'worksheet name')
  #   initialise_sheet(sheet)
  #   remplie_la_feuille(sheet)
  #   retourne_le_contenu_du_xls(workbook)
  # end

  # def content_type_xls
  #   'application/vnd.ms-excel'
  # end

  # def nom_du_fichier
  #   date = DateTime.current.strftime('%Y%m%d')
  #   "#{date}-#{@question.nom_technique}.xls"
  # end
end
