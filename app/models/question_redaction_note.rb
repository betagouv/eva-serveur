# frozen_string_literal: true

class QuestionRedactionNote < Question
  def as_json(_options = nil)
    json = slice(:id, :intitule, :intitule_reponse, :description, :reponse_placeholder)
    json['type'] = 'redaction_note'
    if illustration.attached?
      json['illustration'] = ApplicationController.helpers.cdn_for(illustration)
    end
    json
  end
end
