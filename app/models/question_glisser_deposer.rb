# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponses, -> { order(position: :asc) },
           foreign_key: :question_id,
           class_name: 'Choix',
           dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

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
end
