# frozen_string_literal: true

class QuestionQcm < Question
  enum metacompetence: { numeratie: 0, ccf: 1, "syntaxe-orthographe": 2 }
  enum type_qcm: { standard: 0, jauge: 1 }
  has_many :choix, -> { order(position: :asc) }, foreign_key: :question_id

  accepts_nested_attributes_for :choix, allow_destroy: true

  def as_json(_options = nil)
    json = slice(:id, :intitule, :metacompetence, :type_qcm, :description, :choix)
    json['type'] = 'qcm'
    if illustration.attached?
      json['illustration'] = ApplicationController.helpers.cdn_for(illustration)
    end
    json
  end
end
