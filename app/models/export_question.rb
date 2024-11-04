# frozen_string_literal: true

class ExportQuestion
  WORKSHEET_NAME = 'Données'

  def initialize(question, headers)
    @question = question
    @headers = headers
    @sheet = sheet
  end

  def to_xls
    initialise_feuille
    remplie_la_feuille
    retourne_le_contenu_du_xls
  end

  def content_type_xls
    'application/vnd.ms-excel'
  end

  def nom_du_fichier
    date = DateTime.current.strftime('%Y%m%d')
    "#{date}-#{@question.nom_technique}.xls"
  end

  private

  def sheet
    workbook = Spreadsheet::Workbook.new
    workbook.create_worksheet(name: WORKSHEET_NAME)
  end

  def initialise_feuille
    format_premiere_ligne = Spreadsheet::Format.new(weight: :bold)
    @sheet.row(0).default_format = format_premiere_ligne
    @headers.each_with_index do |entete, colonne|
      @sheet[0, colonne] = entete.to_s.humanize
      @sheet.column(colonne).width = 20
    end
  end

  def remplie_la_feuille
    @headers.each { |_valeur| remplis_champs_commun }
  end

  def remplis_champs_commun
    @sheet[1, 0] = @question.libelle
    @sheet[1, 1] = @question.nom_technique
    @sheet[1, 2] = @question.illustration_url
    @sheet[1, 3] = @question.transcription_intitule&.ecrit
    @sheet[1, 4] = @question.transcription_intitule&.audio_url
    remplis_champs_additionnels
  end

  def remplis_champs_additionnels
    return if @question.sous_consigne?

    @sheet[1, 5] = @question.transcription_modalite_reponse&.ecrit
    @sheet[1, 6] = @question.transcription_modalite_reponse&.audio_url
    @sheet[1, 7] = @question.description
    remplis_champs_specifiques
  end

  def remplis_champs_specifiques
    case @question.type
    when 'QuestionClicDansImage' then remplis_champs_clic_dans_image
    when 'QuestionGlisserDeposer' then remplis_champs_glisser_deposer
    when 'QuestionQcm' then remplis_champs_qcm
    when 'QuestionSaisie' then remplis_champs_saisie
    end
  end

  def remplis_champs_clic_dans_image
    @sheet[1, 8] = @question.zone_cliquable_url
    @sheet[1, 9] = @question.image_au_clic_url
  end

  def remplis_champs_glisser_deposer
    @sheet[1, 8] = @question.zone_depot_url
    @question.reponses.each_with_index { |choix, index| ajoute_reponses(choix, 1, index) }
  end

  def remplis_champs_saisie
    @sheet[1, 8] = @question.suffix_reponse
    @sheet[1, 9] = @question.reponse_placeholder
    @sheet[1, 10] = @question.type_saisie
    return unless @question.bonne_reponse

    @sheet[1, 11] = @question.bonne_reponse.intitule
    @sheet[1, 12] = @question.bonne_reponse.nom_technique
  end

  def remplis_champs_qcm
    @sheet[1, 8] = @question.type_qcm
    @question.choix.each_with_index { |choix, index| ajoute_choix(choix, 1, index) }
  end

  def ajoute_choix(choix, ligne, index)
    columns = %w[intitule nom_technique type_choix audio]
    columns.each_with_index do |col, i|
      @sheet[0, 9 + (index * 4) + i] = "choix_#{index + 1}_#{col}"
      @sheet[ligne, 9 + (index * 4) + i] = choix.send(col)
    end
  end

  def ajoute_reponses(choix, ligne, index)
    columns = %w[nom_technique position_client type_choix illustration]
    columns.each_with_index do |col, i|
      @sheet[0, 9 + (index * 4) + i] = "reponse_#{index + 1}_#{col}"
      @sheet[ligne, 9 + (index * 4) + i] = choix.send(col)
    end
  end

  def retourne_le_contenu_du_xls
    file_contents = StringIO.new
    @sheet.workbook.write file_contents
    file_contents.string
  end
end
