# frozen_string_literal: true

class ImportQuestion
  class Error < StandardError; end
  HEADERS_CLIC_DANS_IMAGE = %i[zone_cliquable image_au_clic].freeze
  HEADERS_GLISSER_DEPOSER = %i[zone_depot].freeze
  HEADERS_QCM = %i[type_qcm].freeze
  HEADERS_SAISIE = %i[suffix_reponse reponse_placeholder type_saisie bonne_reponse_intitule
                      bonne_reponse_nom_technique].freeze
  HEADERS_SOUS_CONSIGNE = %i[libelle nom_technique intitule_ecrit intitule_audio
                             illustration].freeze
  HEADERS_COMMUN = %i[libelle nom_technique description intitule_ecrit intitule_audio
                      consigne_ecrit consigne_audio illustration].freeze

  def initialize(type)
    @type = type
  end

  def remplis_donnees(file)
    sheet = Spreadsheet.open(file.path).worksheet(0)
    raise Error, message_erreur_headers unless headers_valides?(sheet.rows[0])

    creation_question(sheet.rows[1])
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

  def headers_valides?(headers)
    headers_serialises = headers.map { |header| header.parameterize.underscore.to_sym if header }
    headers_serialises == headers_attendus
  end

  def headers_attendus
    headers = {
      'QuestionClicDansImage' => HEADERS_COMMUN + HEADERS_CLIC_DANS_IMAGE,
      'QuestionGlisserDeposer' => HEADERS_COMMUN + HEADERS_GLISSER_DEPOSER,
      'QuestionQcm' => HEADERS_COMMUN + HEADERS_QCM,
      'QuestionSaisie' => HEADERS_SAISIE + HEADERS_SAISIE,
      'QuestionSousConsigne' => HEADERS_SOUS_CONSIGNE
    }

    headers[@type]
  end

  def creation_question(data)
    ActiveRecord::Base.transaction do
      @question = Question.create!(type: @type, libelle: data[0],
                                   nom_technique: data[1], description: data[2])
      telecharge_illustration(data[7])
      cree_transcription(:intitule, data[4], data[3])
      cree_transcription(:modalite_reponse, data[6], data[5])
      cree_champs_specifiques(data)
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

  def cree_champs_specifiques(data)
  end

  def cree_reponses(data)
    extraie_colonne_reponses.each do |data_reponse|
      cree_reponse(data_reponse)
    end
  end

  def cree_reponse(data_reponse)
    Choix.create!
  end

  def telecharge_fichier(url)
    @current_download = url
    fichier = Down.download(url)
    {
      io: fichier,
      filename: fichier.original_filename,
      content_type: fichier.content_type
    }
  end

  def extraie_colonne_reponses
    # je parcours les colonnes
    # je prends que celle qui commence par "reponse_"
    # je regroupe les colonnes par ID

    # /reponse_(\d+)_/

    # je retourne un objet du type :
    # {
    #   1: {
    #     libelle:
    #     nom_technique
    #   },
    #   2: {
    #     ...
    #   }
    # }
  end
end
