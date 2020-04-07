# frozen_string_literal: true

class QuestionQcm < Question
  enum metacompetence: %i[numeratie ccf syntaxe-orthographe]
  has_many :choix, -> { order(position: :asc) }, foreign_key: :question_id

  accepts_nested_attributes_for :choix, allow_destroy: true

  def as_json(_options = nil)
    json = slice(:id, :intitule, :metacompetence, :description, :choix)
    json['type'] = 'qcm'
    if illustration.attached?
      json['illustration'] = Rails.application.routes.url_helpers.url_for(illustration)
    end
    json
  end
end
