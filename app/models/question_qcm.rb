# frozen_string_literal: true

class QuestionQcm < Question
  enum :metacompetence, { numeratie: 0, ccf: 1, 'syntaxe-orthographe': 2 }
  enum :type_qcm, { standard: 0, jauge: 1 }
  has_many :choix, lambda {
                     order(position: :asc)
                   }, foreign_key: :question_id,
                      dependent: :destroy

  accepts_nested_attributes_for :choix, allow_destroy: true

  def restitue_reponse(reponse)
    choix.find { |c| c.nom_technique == reponse }.intitule
  end

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
          :illustration).tap do |json|
      json['type'] = 'qcm'
      json['illustration'] = cdn_for(illustration)
    end
  end

  def additional_json_fields
    {
      'intitule' => transcription_intitule&.ecrit,
      'modalite_reponse' => transcription_modalite_reponse&.ecrit,
      'choix' => question_choix
    }
  end

  def question_choix
    choix.map do |choix|
      audio_url = cdn_for(choix.audio) if choix&.audio&.attached?
      choix.slice(:id, :nom_technique, :intitule, :type_choix, :position).merge(
        'audio_url' => audio_url
      )
    end
  end
end
