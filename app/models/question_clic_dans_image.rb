# frozen_string_literal: true

class QuestionClicDansImage < Question
  def as_json(_options = nil)
    json = base_json_object
    json.merge!(additional_json_fields(transcription_intitule, transcription_modalite_reponse))
  end

  private

  def base_json_object
    slice(:id, :nom_technique).tap do |json|
      json['type'] = 'clic_dans_image'
      json['illustration'] = cdn_for(illustration)
      json['description'] = description
    end
  end

  def additional_json_fields(intitule, modalite)
    fields = { 'intitule' => intitule&.ecrit,
               'modalite_reponse' => modalite&.ecrit,
               'audio_url' => question_audio_principal(intitule, modalite) }
    if question_audio_secondaire(intitule)
      fields['intitule_audio'] = question_audio_secondaire(intitule)
    end
    fields
  end

  def question_audio_principal(intitule, modalite)
    if intitule&.ecrit.present? && intitule.audio.attached?
      cdn_for(intitule.audio)
    elsif modalite&.ecrit.present? && modalite.audio.attached?
      cdn_for(modalite.audio)
    end
  end

  def cdn_for(attachment)
    ApplicationController.helpers.cdn_for(attachment) if attachment.attached?
  end

  def question_audio_secondaire(intitule)
    return unless intitule&.ecrit.blank? && intitule.audio.attached?

    cdn_for(intitule.audio)
  end
end
