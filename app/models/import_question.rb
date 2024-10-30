# frozen_string_literal: true

class ImportQuestion
  class Error < StandardError; end
  HEADERS_CLIC_DANS_IMAGE = %i[zone_cliquable image_au_clic].freeze
  HEADERS_GLISSER_DEPOSER = %i[zone_depot].freeze
  HEADERS_QCM = %i[type_qcm].freeze
  HEADERS_SAISIE = %i[suffix_reponse reponse_placeholder type_saisie bonne_reponse_intitule
                      bonne_reponse_nom_technique].freeze
  HEADERS_SOUS_CONSIGNE = %i[libelle nom_technique illustration intitule_ecrit
                             intitule_audio].freeze
  HEADERS_COMMUN = %i[libelle nom_technique illustration intitule_ecrit intitule_audio
                      consigne_ecrit consigne_audio description].freeze

  def initialize(type)
    @type = type
  end

  def remplis_donnees(file)
    sheet = Spreadsheet.open(file.path).worksheet(0)
    @data = sheet.rows[1]
    @headers = sheet.rows[0]
    raise Error, message_erreur_headers unless headers_valides?

    creation_question
  rescue ActiveRecord::RecordInvalid => e
    raise Error, message_erreur_validation(e)
  rescue Down::Error
    raise Error, message_erreur_telechargement
  end

  private

  def message_erreur_validation(exception)
    exception.record.errors.full_messages.to_sentence.to_s
  end

  def message_erreur_telechargement
    "Impossible de télécharger un fichier depuis l'url : #{@current_download}"
  end

  def message_erreur_headers
    I18n.t('.layouts.erreurs.import_question.mauvais_format', headers: headers_attendus.map do |h|
      h.to_s.tr('_', ' ')
    end.join(', '))
  end

  def headers_valides?
    headers_serialises = @headers.map { |header| header.parameterize.underscore.to_sym if header }
    headers_serialises[0, headers_attendus.length] == headers_attendus
  end

  def headers_attendus
    headers = {
      'QuestionClicDansImage' => HEADERS_COMMUN + HEADERS_CLIC_DANS_IMAGE,
      'QuestionGlisserDeposer' => HEADERS_COMMUN + HEADERS_GLISSER_DEPOSER,
      'QuestionQcm' => HEADERS_COMMUN + HEADERS_QCM,
      'QuestionSaisie' => HEADERS_COMMUN + HEADERS_SAISIE,
      'QuestionSousConsigne' => HEADERS_SOUS_CONSIGNE
    }

    headers[@type]
  end

  def creation_question
    ActiveRecord::Base.transaction do
      @question = Question.create!(type: @type, libelle: @data[0],
                                   nom_technique: @data[1], description: @data[7])
      telecharge_illustration(@data[2])
      cree_transcription(:intitule, @data[4], @data[3])
      unless @type == 'QuestionSousConsigne'
        cree_transcription(:modalite_reponse, @data[6],
                           @data[5])
      end
      update_champs_specifiques
    end

    @question
  end

  def cree_transcription(categorie, audio_url, ecrit)
    transcription = Transcription.create!(ecrit: ecrit, question_id: @question.id,
                                          categorie: categorie)
    return if audio_url.blank?

    transcription.audio.attach(telecharge_fichier(audio_url))
  end

  def telecharge_illustration(url)
    return if url.blank?

    @question.illustration.attach(telecharge_fichier(url))
  end

  def update_champs_specifiques
    case @type
    when 'QuestionClicDansImage'
      update_clic_dans_image
    when 'QuestionGlisserDeposer'
      update_glisser_deposer
    when 'QuestionQcm'
      update_qcm
    when 'QuestionSaisie'
      update_saisie
    end
  end

  def update_clic_dans_image
    @question.zone_cliquable.attach(telecharge_fichier(@data[8]))
    @question.image_au_clic.attach(telecharge_fichier(@data[9]))
  end

  def update_glisser_deposer
    @question.zone_depot.attach(telecharge_fichier(@data[8]))
    cree_reponses
  end

  def update_qcm
    @question.update!(type_qcm: @data[8])
    cree_choix
  end

  def update_saisie
    @question.update!(suffix_reponse: @data[8], reponse_placeholder: @data[9],
                      type_saisie: @data[10])
    cree_bonne_reponse
  end

  def cree_choix
    extraie_colonne('choix').each_value do |data_choix|
      cree_chaque_choix(data_choix)
    end
  end

  def cree_reponses
    extraie_colonne('reponse').each_value do |data_reponse|
      cree_reponse(data_reponse)
    end
  end

  def cree_bonne_reponse
    Choix.create!(
      intitule: @data[11],
      nom_technique: @data[12],
      question_id: @question.id,
      type_choix: 'bon'
    )
  end

  def cree_chaque_choix(data)
    choix = Choix.create!(
      intitule: data['intitule'],
      nom_technique: data['nom_technique'],
      question_id: @question.id,
      type_choix: data['type_choix']
    )
    choix.audio.attach(telecharge_fichier(data['audio']))
  end

  def cree_reponse(data)
    reponse = Choix.create!(
      nom_technique: data['nom_technique'],
      position_client: data['position_client'],
      type_choix: data['type_choix'],
      question_id: @question.id
    )
    reponse.illustration.attach(telecharge_fichier(data['illustration']))
  end

  def telecharge_fichier(url)
    @current_download = url
    return unless url

    fichier = Down.download(url)
    content_type = Marcel::MimeType.for(fichier.path, name: fichier.original_filename)

    {
      io: fichier,
      filename: fichier.original_filename,
      content_type: content_type
    }
  end

  def extraie_colonne(reponse)
    headers_data = {}

    @headers.each_with_index do |header, index|
      next unless header.to_s.match(/#{reponse}_(\d+)_/)

      item = header.match(/#{reponse}_(\d+)_/)[1].to_i
      data_type = header.match(/#{reponse}_\d+_(.*)/)[1]

      headers_data[item] = {} if headers_data[item].nil?
      headers_data[item][data_type] = @data[index]
    end

    headers_data
  end
end
