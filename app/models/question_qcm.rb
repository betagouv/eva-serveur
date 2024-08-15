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
    illustration_url = cdn_for(illustration) if illustration.attached?
    audio_url = cdn_for(transcription.audio) if transcription&.audio&.attached?
    json_object(transcription&.ecrit, illustration_url, audio_url)
  end

  private

  def json_object(intitule, illustration, audio)
    json = slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
                 :illustration)
    json['type'] = 'qcm'
    json['intitule'] = intitule
    json['illustration'] = illustration
    json['audio_url'] = audio
    json['choix'] = question_choix
    json
  end

  def question_choix
    choix.map do |choix|
      audio_url = cdn_for(choix.audio) if choix&.audio&.attached?
      choix.slice(:id, :nom_technique, :intitule, :type_choix, :position).merge(
        'audio_url' => audio_url
      )
    end
  end

  def cdn_for(attachment)
    ApplicationController.helpers.cdn_for(attachment)
  end
end
