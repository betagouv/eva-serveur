# frozen_string_literal: true

class ImportQuestion
  ## TODO rajouter les réponses et choix
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
    spreadsheet = Spreadsheet.open(file.path)
    sheet = spreadsheet.worksheet(0)
    ## TODO return une erreur si le fichier n'est pas valide
    return unless headers_valides?(sheet.rows[0])

    genere_nouvelle_question(sheet.rows[1])
  end

  private

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

  def genere_nouvelle_question(data)
    # #TODO retourne une erreur si nom-technique est déjà utilisé
    @question = Question.create(type: @type, libelle: data[0],
                                nom_technique: data[1], description: data[2])
    cree_transcription(:intitule, data[4], data[3])
    cree_transcription(:modalite_reponse, data[6], data[5])

    @question
  end

  def cree_transcription(categorie, audio_url, ecrit)
    transcription = Transcription.create!(ecrit: ecrit, question_id: @question.id,
                                          categorie: categorie)
    return if audio_url.blank?

    audio_file = Down.download(audio_url)
    audio_blob = ActiveStorage::Blob.create_and_upload!(
      io: audio_file,
      filename: 'audio.mp3',
      content_type: 'audio/mpeg'
    )
    transcription.audio.attach(audio_blob)
  end
end
