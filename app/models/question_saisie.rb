# frozen_string_literal: true

class QuestionSaisie < Question
  def as_json(_options = nil)
    json = slice(:id, :intitule, :nom_technique, :intitule_reponse, :description,
                 :reponse_placeholder)
    json['type'] = 'saisie'
    json
  end
end
