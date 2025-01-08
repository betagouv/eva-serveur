# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  QUESTION_TYPE = 'QuestionGlisserDeposer'
  has_many :reponses, -> { order(position: :asc) },
           foreign_key: :question_id,
           class_name: 'Choix',
           dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  enum :metacompetence, Metacompetence::METACOMPETENCES

  has_one_attached :zone_depot

  validates :zone_depot,
            blob: { content_type: 'image/svg+xml' }

  attr_accessor :supprimer_zone_depot

  before_save :valide_zone_depot_avec_reponse
  after_update :supprime_zone_depot

  def as_json(_options = nil)
    json = base_json
    json['zone_depot_url'] = svg_attachment_base64(zone_depot) if zone_depot.attached?
    json.merge!(json_audio_fields, reponses_fields)
  end

  def zone_depot_url
    cdn_for(zone_depot)
  end

  def self.preload_assocations_pour_as_json
    base_includes_pour_as_json + [:zone_depot_attachment, { reponses: :illustration_attachment }]
  end

  private

  def base_json
    slice(:id, :nom_technique, :description, :demarrage_audio_modalite_reponse,
          :score, :metacompetence).tap do |json|
      json['type'] = 'glisser-deposer'
      json['illustration'] = cdn_for(illustration) if illustration.attached?
      json['modalite_reponse'] = transcription_modalite_reponse&.ecrit
      json['intitule'] = transcription_intitule&.ecrit
    end
  end

  def reponses_fields
    reponses_non_classees = reponses.map do |reponse|
      illustration_url = cdn_for(reponse.illustration) if reponse.illustration.attached?
      reponse.slice(:id, :position, :nom_technique, :position_client, :intitule).merge(
        'illustration' => illustration_url
      )
    end
    { 'reponsesNonClassees' => reponses_non_classees }
  end

  def supprime_zone_depot
    zone_depot.purge_later if zone_depot.attached? && supprimer_zone_depot == '1'
  end

  def valide_zone_depot_avec_reponse
    return unless zone_depot.attached? && attachment_changes['zone_depot']

    file = attachment_changes['zone_depot'].attachable
    invalid_zone_depot_error unless svg_contient_classes?(file)
  end

  def invalid_zone_depot_error
    errors.add(:zone_depot,
               "doit contenir les classes 'zone-depot zone-depot--reponse-nom-technique'")
    throw(:abort)
  end

  def svg_contient_classes?(svg_content)
    doc = ApplicationController.helpers.parse_svg_content(svg_content)
    doc.css('.zone-depot').any? do |element|
      element[:class].split.any? do |cls|
        cls.start_with?('zone-depot--')
      end
    end
  end
end
