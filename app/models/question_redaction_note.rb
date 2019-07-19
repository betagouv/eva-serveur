# frozen_string_literal: true

class QuestionRedactionNote < Question
  def as_json(_options = nil)
    json = slice(:id, :intitule, :entete_reponse, :expediteur, :message, :objet_reponse)
    json['type'] = 'redaction_note'
    json
  end
end
