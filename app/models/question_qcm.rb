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
    illustration_url = ApplicationController.helpers.cdn_for(illustration) if illustration.attached?
    if transcription&.audio&.attached?
      audio_url = ApplicationController.helpers.cdn_for(transcription&.audio)
    end
    json_object(transcription&.ecrit, illustration_url, audio_url)
  end

  private

  def json_object(intitule, illustration, audio)
    json = slice(:id, :nom_technique, :metacompetence, :type_qcm, :description, :choix,
                 :illustration)
    json['type'] = 'qcm'
    json['intitule'] = intitule
    json['illustration'] = illustration
    json['audio_url'] = audio
    json
  end
end
