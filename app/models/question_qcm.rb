# frozen_string_literal: true

class QuestionQcm < Question
  QUESTION_TYPE = 'QuestionQcm'

  enum :metacompetence, Metacompetence::METACOMPETENCES

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

  def liste_choix
    choix.pluck(:intitule).join(' | ')
  end

  def bonnes_reponses
    choix.where(type_choix: :bon)&.pluck(:intitule)&.join(' | ')
  end

  def self.preload_assocations_pour_as_json
    base_includes_pour_as_json + [{ choix: :audio_attachment }]
  end

  private

  def base_json
    slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
          :demarrage_audio_modalite_reponse, :illustration, :score, :metacompetence).tap do |json|
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
