# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  enum :type_saisie, { redaction: 0, numerique: 1 }

  def as_json(_options = nil)
    transcription = Transcription.find_by(categorie: :intitule, question_id: id)
    json = slice(:id, :nom_technique, :suffix_reponse, :description)
    json['type'] = 'saisie'
    json['intitule'] = transcription&.ecrit
    json['sous_type'] = type_saisie
    json['placeholder'] = reponse_placeholder
    json
  end
end
