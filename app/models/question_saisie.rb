# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  enum :type_saisie, { redaction: 0, numerique: 1 }

  has_one :bonne_reponse, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :bonne_reponse, allow_destroy: true

  def as_json(_options = nil)
    json = base_json_object
    json.merge!(additional_json_fields(transcription_intitule, transcription_modalite_reponse))
  end

  private

  def base_json_object
    slice(:id, :nom_technique, :suffix_reponse, :description,
          :illustration).tap do |json|
      json['type'] = 'saisie'
      json['illustration'] = cdn_for(illustration)
      json['sous_type'] = type_saisie
      json['placeholder'] = reponse_placeholder
      json['description'] = description
    end
  end

  def additional_json_fields(intitule, modalite)
    fields = { 'intitule' => intitule&.ecrit,
               'modalite_reponse' => modalite&.ecrit,
               'audio_url' => question_audio_principal(intitule, modalite),
               'reponse' => { 'textes' => bonne_reponse&.intitule,
                              'bonneReponse' => bonne_reponse&.type_choix == 'bon' } }
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
    return unless intitule&.ecrit.blank? && intitule&.audio&.attached?

    cdn_for(intitule.audio)
  end
end
