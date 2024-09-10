# frozen_string_literal: true

class QuestionGlisserDeposer < Question
  has_many :reponses, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  def as_json(_options = nil)
    json = base_json
    json.merge!(audio_fields, reponses_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique, :description).tap do |json|
      json['type'] = 'glisser_deposer_billets'
      json['illustration'] = cdn_for(illustration) if illustration.attached?
      json['modalite_reponse'] = transcription_modalite_reponse&.ecrit
      json['intitule'] = transcription_intitule&.ecrit
    end
  end

  def audio_fields
    fields = { 'audio_url' => audio_principal }
    if transcription_intitule&.ecrit.blank? && transcription_intitule&.audio_url
      fields['intitule_audio'] = transcription_intitule&.audio_url
    end
    fields
  end

  def audio_principal
    return unless intitule_complet? || modalite_complete?
    return transcription_intitule.audio_url if intitule_complet?

    transcription_modalite_reponse.audio_url
  end

  def reponses_fields
    reponses_non_classees = reponses.map do |reponse|
      illustration_url = cdn_for(reponse.illustration) if reponse.illustration.attached?
      reponse.slice(:id, :position).merge(
        'illustration' => illustration_url
      )
    end
    { 'reponsesNonClassees' => reponses_non_classees }
  end
end
