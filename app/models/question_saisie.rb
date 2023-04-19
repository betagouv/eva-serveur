# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'

  enum :type_saisie, { redaction: 0, numerique: 1 }

  def as_json(_options = nil)
    json = slice(:id, :intitule, :nom_technique, :suffix_reponse, :description)
    json['type'] = 'saisie'
    json['sous_type'] = type_saisie
    json['placeholder'] = reponse_placeholder
    json
  end
end
