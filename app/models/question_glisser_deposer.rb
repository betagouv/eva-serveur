# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponse, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :reponse, allow_destroy: true

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :description)
  end
end
