# frozen_string_literal: true

class QuestionQcm < Question
  has_many :choix, -> { order(position: :asc) }, foreign_key: :question_id

  accepts_nested_attributes_for :choix, allow_destroy: true

  def as_json(_options = nil)
    json = slice(:id, :intitule, :description, :choix)
    json['type'] = 'qcm'
    json
  end
end
