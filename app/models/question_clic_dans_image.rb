# frozen_string_literal: true

class QuestionClicDansImage < Question
  CLASS_BONNE_REPONSE = 'bonne-reponse'
  QUESTION_TYPE = 'QuestionClicDansImage'

  has_one_attached :zone_cliquable
  has_one_attached :image_au_clic

  validates :zone_cliquable,
            blob: { content_type: 'image/svg+xml' }
  validates :image_au_clic,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_cliquable, :supprimer_image_au_clic

  before_save :valide_zone_cliquable_avec_reponse
  after_update :supprime_zone_cliquable, :supprime_image_au_clic

  def as_json(_options = nil)
    json = base_json
    json['image_au_clic'] = fichier_encode_base64(image_au_clic) if image_au_clic.attached?
    json.merge!(json_audio_fields, additional_json_fields)
  end

  def clic_multiple?
    return false unless zone_cliquable.attached?

    svg_content = zone_cliquable.download
    svg_contient_class_bonne_reponse?(svg_content, 2)
  end

  def zone_cliquable_url
    cdn_for(zone_cliquable)
  end

  def image_au_clic_url
    cdn_for(image_au_clic)
  end

  private

  def base_json
    slice(:id, :nom_technique, :demarrage_audio_modalite_reponse).tap do |json|
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

  def supprime_image_au_clic
    image_au_clic.purge_later if image_au_clic.attached? && supprimer_image_au_clic == '1'
  end

  def valide_zone_cliquable_avec_reponse
    return unless zone_cliquable.attached?
    return if attachment_changes['zone_cliquable'].nil?

    file = attachment_changes['zone_cliquable'].attachable
    return if svg_contient_class_bonne_reponse?(file, 1)

    errors.add(:zone_cliquable, :class_bonne_reponse_not_found)
    throw(:abort)
  end

  def svg_contient_class_bonne_reponse?(svg_content, minimum)
    doc = ApplicationController.helpers.parse_svg_content(svg_content)
    doc.css(".#{CLASS_BONNE_REPONSE}").size >= minimum
  end

  def fichier_encode_base64(attachment)
    file_content = attachment.download
    ApplicationController.helpers.fichier_encode_en_base64(file_content)
  end
end
