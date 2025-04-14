# frozen_string_literal: true

class QuestionSousConsigne < Question
  QUESTION_TYPE = "QuestionSousConsigne"

  def as_json(_options = nil)
    json = slice(:id, :nom_technique)
    json["type"] = "sous-consigne"
    json["intitule"] = transcription_intitule&.ecrit
    json["illustration"] = illustration_url
    json["audio_url"] = transcription_intitule&.audio_url
    json
  end
end
