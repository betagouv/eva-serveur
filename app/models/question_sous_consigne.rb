# frozen_string_literal: true

class QuestionSousConsigne < Question
  def as_json(_options = nil)
    json = slice(:id, :intitule, :nom_technique)
    json['type'] = 'sous-consigne'
    json
  end
end
