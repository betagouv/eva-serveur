# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  QUESTION_TYPE = 'QuestionSaisie'

  enum :type_saisie, { redaction: 0, numerique: 1 }

  has_one :bonne_reponse, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :bonne_reponse, allow_destroy: true

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique, :suffix_reponse, :description,
          :illustration).tap do |json|
      json['type'] = 'saisie'
      json['illustration'] = cdn_for(illustration)
      json['sous_type'] = type_saisie
      json['placeholder'] = reponse_placeholder
      json['description'] = description
    end
  end

  def additional_json_fields
    if bonne_reponse
      reponse = { 'textes' => bonne_reponse.intitule,
                  'bonneReponse' => bonne_reponse.type_choix == 'bon' }
    end
    { 'intitule' => transcription_intitule&.ecrit,
      'modalite_reponse' => transcription_modalite_reponse&.ecrit,
      'reponse' => reponse }
  end
end
