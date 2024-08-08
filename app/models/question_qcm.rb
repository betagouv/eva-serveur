# frozen_string_literal: true

class QuestionQcm < Question
  enum :metacompetence, { numeratie: 0, ccf: 1, 'syntaxe-orthographe': 2 }
  enum :type_qcm, { standard: 0, jauge: 1 }
  has_many :choix, lambda {
                     order(position: :asc)
                   }, foreign_key: :question_id,
                      dependent: :destroy

  accepts_nested_attributes_for :choix, allow_destroy: true

  def as_json(_options = nil)
    transcription = Transcription.find_by(categorie: :intitule, question_id: id)
    json = slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
                 :choix)
    json['type'] = 'qcm'
    json['intitule'] = transcription&.ecrit
    json
  end
end
