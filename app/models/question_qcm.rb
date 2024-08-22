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
    intitule = transcription_intitule
    modalite = Transcription.find_by(categorie: :modalite_reponse, question_id: id)
    illustration_url = cdn_for(illustration) if illustration.attached?
    json_object(intitule, modalite, illustration_url)
  end

  private

  def json_object(intitule, modalite, illustration)
    json = base_json_object(illustration)
    json.merge!(additional_json_fields(intitule, modalite))
  end

  def base_json_object(illustration)
    slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
          :illustration).tap do |json|
      json['type'] = 'qcm'
      json['illustration'] = illustration
    end
  end

  def additional_json_fields(intitule, modalite)
    fields = {
      'intitule' => intitule&.ecrit,
      'modalite_reponse' => modalite&.ecrit,
      'audio_url' => question_audio_principal(intitule, modalite),
      'choix' => question_choix
    }
    if question_audio_secondaire(intitule)
      fields['intitule_audio'] = question_audio_secondaire(intitule)
    end

    fields
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

  def question_audio_principal(intitule, modalite)
    if intitule&.ecrit.present? && intitule.audio.attached?
      cdn_for(intitule.audio)
    elsif modalite&.ecrit.present? && modalite.audio.attached?
      cdn_for(modalite.audio)
    end
  end

  def question_audio_secondaire(intitule)
    return unless intitule
    return unless intitule.ecrit.blank? && intitule.audio.attached?

    cdn_for(intitule.audio)
  end
end
