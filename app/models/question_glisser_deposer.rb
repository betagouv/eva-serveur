# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponses, -> { order(position: :asc) },
           foreign_key: :question_id,
           class_name: 'Choix',
           dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  has_many_attached :zones_depot_url

  validates :zones_depot_url,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zones_depot_url

  before_save :valide_zones_depot_url_avec_reponse
  after_update :supprime_zones_depot_url

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

  def supprime_zones_depot_url
    zones_depot_url.purge_later if zones_depot_url.attached? && supprimer_zones_depot_url == '1'
  end

  def valide_zones_depot_url_avec_reponse
    return unless zones_depot_url_attached?
    return if zones_depot_url_changes_nil?

    attachment_changes['zones_depot_url'].attachable.each do |file|
      doc = Nokogiri::XML(file.download, nil, 'UTF-8')

      if zones_depot_invalid?(doc)
        add_invalid_zones_depot_error
        throw(:abort)
      end
    end
  end

  def zones_depot_url_attached?
    zones_depot_url.attached?
  end

  def zones_depot_url_changes_nil?
    attachment_changes['zones_depot_url'].nil?
  end

  def zones_depot_invalid?(doc)
    doc.css('.zone-depot').empty? || doc.css(".zone-depot--#{reponse.nom_technique}").empty?
  end

  def add_invalid_zones_depot_error
    errors.add(:zones_depot_url,
               "doit contenir les classes 'zone-depot' et 'zone-depot--#{reponse.nom_technique}'")
  end
end
