# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponses, -> { order(position: :asc) },
           foreign_key: :question_id,
           class_name: 'Choix',
           dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  has_one_attached :zone_depot_url

  validates :zone_depot_url,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_depot_url

  before_save :valide_zone_depot_url_avec_reponse
  after_update :supprime_zone_depot_url

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, reponses_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique, :description).tap do |json|
      json['type'] = 'glisser-deposer-billets'
      json['illustration'] = cdn_for(illustration) if illustration.attached?
      json['modalite_reponse'] = transcription_modalite_reponse&.ecrit
      json['intitule'] = transcription_intitule&.ecrit
    end
  end

  def reponses_fields
    reponses_non_classees = reponses.map do |reponse|
      illustration_url = cdn_for(reponse.illustration) if reponse.illustration.attached?
      reponse.slice(:id, :position, :position_client).merge(
        'illustration' => illustration_url
      )
    end
    { 'reponsesNonClassees' => reponses_non_classees }
  end

  def supprime_zone_depot_url
    zone_depot_url.purge_later if zone_depot_url.attached? && supprimer_zone_depot_url == '1'
  end

  def valide_zone_depot_url_avec_reponse
    return unless zone_depot_url.attached?
    return if attachment_changes['zone_depot_url'].nil?

    file = attachment_changes['zone_depot_url'].attachable
    doc = Nokogiri::XML(file, nil, 'UTF-8')
    return unless elements_depot(doc).empty?

    invalid_zone_depot_error(reponse)
  end

  def invalid_zone_depot_error(reponse)
    errors.add(:zone_depot_url,
               "doit contenir les classes 'zone-depot' et 'zone-depot--#{reponse.nom_technique}'")
    throw(:abort)
  end

  def elements_depot(doc)
    doc.css('.zone-depot') || doc.css(".zone-depot--#{reponse.nom_technique}")
  end
end
