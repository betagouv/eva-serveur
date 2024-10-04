# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponses, -> { order(position: :asc) },
           foreign_key: :question_id,
           class_name: 'Choix',
           dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  has_one_attached :zone_depot

  validates :zone_depot,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_depot

  before_save :valide_zone_depot_avec_reponse
  after_update :supprime_zone_depot

  def as_json(_options = nil)
    json = base_json
    json['zone_depot_url'] = cdn_for(zone_depot) if zone_depot.attached?
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

  def supprime_zone_depot
    zone_depot.purge_later if zone_depot.attached? && supprimer_zone_depot == '1'
  end

  def valide_zone_depot_avec_reponse
    return unless zone_depot.attached?
    return if attachment_changes['zone_depot'].nil?

    file = attachment_changes['zone_depot'].attachable
    doc = Nokogiri::XML(file, nil, 'UTF-8')

    return unless elements_depot(doc).empty?

    invalid_zone_depot_error
  end

  def invalid_zone_depot_error
    errors.add(:zone_depot,
               "doit contenir les classes 'zone-depot zone-depot--reponse-nom-technique'")
    throw(:abort)
  end

  def elements_depot(doc)
    doc.css('.zone-depot').select do |element|
      element[:class].split.any? { |cls| cls.start_with?('zone-depot--') }
    end
  end
end
