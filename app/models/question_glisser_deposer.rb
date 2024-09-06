# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :description)
  end
end
