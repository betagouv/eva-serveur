# frozen_string_literal: true

class QuestionClicDansImage < Question
  has_one_attached :zone_cliquable

  validates :zone_cliquable,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_cliquable

  before_save :valide_zone_cliquable_avec_reponse
  after_update :supprime_zone_cliquable

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique).tap do |json|
      json['type'] = 'clic-dans-image'
      json['illustration'] = cdn_for(illustration) if illustration.attached?
      json['description'] = description
      json['zone_cliquable'] = fichier_encode_base64(zone_cliquable) if zone_cliquable.attached?
    end
  end

  def additional_json_fields
    { 'intitule' => transcription_intitule&.ecrit,
      'modalite_reponse' => transcription_modalite_reponse&.ecrit }
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
