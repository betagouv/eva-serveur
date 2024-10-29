# frozen_string_literal: true

class ImportQuestion
  HEADERS_CLIC_DANS_IMAGE = %i[libelle nom_technique description intitule_ecrit intitule_audio
                               consigne_ecrit consigne_audio illustration zone_cliquable
                               image_au_clic].freeze

  def initialize(type)
    @type = type
    @question = Question.new
  end

  def preremplis_donnees(file)
    spreadsheet = Spreadsheet.open(file.path)
    sheet = spreadsheet.worksheet(0)
    return unless headers_valides?(sheet.rows[0])

    genere_nouvelle_question(sheet.rows[1])
  end

  private

  def headers_valides?(headers)
    headers_serialises = headers.map { |header| header.parameterize.underscore.to_sym if header }
    headers_serialises == headers_attendus
  end

  def headers_attendus
    case @type
    when 'QuestionClicDansImage'
      HEADERS_CLIC_DANS_IMAGE
    end
  end

  def genere_nouvelle_question(data)
    @question = Question.create!(type: @type, libelle: data[0],
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
