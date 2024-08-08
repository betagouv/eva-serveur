# frozen_string_literal: true

class QuestionSousConsigne < Question
  def as_json(_options = nil)
    transcription = Transcription.find_by(categorie: :intitule, question_id: id)
    json = slice(:id, :nom_technique)
    json['type'] = 'sous-consigne'
    json['intitule'] = transcription&.ecrit
    json
  end
end
