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
    question = Question.create(type: @type, libelle: data[0],
                               nom_technique: data[1], description: data[2])
    Transcription.create(ecrit: data[3], question_id: question.id,
                         categorie: :intitule)
    Transcription.create(ecrit: data[5], question_id: question.id,
                         categorie: :modalite_reponse)
    question
  end
end
