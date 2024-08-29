# frozen_string_literal: true

class QuestionClicDansImage < Question
  has_one_attached :zone_cliquable

  validates :zone_cliquable,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_cliquable

  before_save :valide_zone_cliquable_avec_reponse
  after_update :supprime_zone_cliquable

  def as_json(_options = nil)
    json = base_json_object
    json.merge!(additional_json_fields(transcription_intitule, transcription_modalite_reponse))
  end

  private

  def base_json_object
    slice(:id, :nom_technique).tap do |json|
      json['type'] = 'clic_dans_image'
      json['illustration'] = cdn_for(illustration) if illustration.attached?
      json['description'] = description
      json['zone_cliquable'] = fichier_encode_base64(zone_cliquable) if zone_cliquable.attached?
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
    return unless intitule&.ecrit.blank? && intitule&.audio&.attached?

    cdn_for(intitule.audio)
  end

  def supprime_zone_cliquable
    zone_cliquable.purge_later if zone_cliquable.attached? && supprimer_zone_cliquable == '1'
  end

  def valide_zone_cliquable_avec_reponse
    return unless zone_cliquable.attached?
    return if attachment_changes['zone_cliquable'].nil?

    file = attachment_changes['zone_cliquable'].attachable
    doc = Nokogiri::XML(file, nil, 'UTF-8')
    elements_cliquables = doc.css('.bonne-reponse')

    return unless elements_cliquables.empty?

    errors.add(:zone_cliquable, "doit contenir la classe 'bonne_reponse'")
    throw(:abort)
  end

  def fichier_encode_base64(attachment)
    file_content = attachment.download
    ApplicationController.helpers.fichier_encode_en_base64(file_content)
  end
end
