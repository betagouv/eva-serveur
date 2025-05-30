# frozen_string_literal: true

class QuestionQcm < Question
  QUESTION_TYPE = "QuestionQcm"

  enum :type_qcm, { standard: 0, jauge: 1 }

  has_many :choix, lambda {
                     order(position: :asc)
                   }, foreign_key: :question_id,
                      dependent: :destroy

  accepts_nested_attributes_for :choix, allow_destroy: true

  def restitue_reponse(nom_technique_reponse)
    choix.find { |c| c.nom_technique == nom_technique_reponse }.intitule
  end

  def intitule_reponse(reponse)
    c = choix.find_by(id: reponse)
    return reponse if c.nil?

    c.intitule.presence || c.nom_technique
  end

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  def reponses_possibles
    choix.map { |c| c.intitule.presence || c.nom_technique }.join(" | ")
  end

  def bonnes_reponses
    choix.where(type_choix: :bon).map { |c| c.intitule.presence || c.nom_technique }.join(" | ")
  end

  def self.preload_assocations_pour_as_json
    base_includes_pour_as_json + [ { choix: { audio_attachment: :blob } } ]
  end

  private

  def base_json
    slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
          :demarrage_audio_modalite_reponse, :illustration, :score, :metacompetence).tap do |json|
      json["type"] = "qcm"
      json["illustration"] = illustration_url
    end
  end

  def additional_json_fields
    {
      "intitule" => transcription_intitule&.ecrit,
      "modalite_reponse" => transcription_modalite_reponse&.ecrit,
      "choix" => question_choix
    }
  end

  def question_choix
    choix.map do |choix|
      audio_url = cdn_for(choix.audio) if choix&.audio&.attached?
      choix.slice(:id, :nom_technique, :intitule, :type_choix, :position).merge(
        "audio_url" => audio_url
      )
    end
  end
end
