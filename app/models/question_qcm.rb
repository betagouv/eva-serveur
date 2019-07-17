# frozen_string_literal: true

class QuestionQcm < Question
  has_many :choix, -> { order(position: :asc) }, foreign_key: :question_id

  accepts_nested_attributes_for :choix, allow_destroy: true
end
