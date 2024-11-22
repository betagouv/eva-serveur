# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  QUESTION_TYPE = 'QuestionSaisie'

  enum :type_saisie, { redaction: 0, numerique: 1, texte: 2 }

  has_many :reponses, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  def bonnes_reponses
    reponses.where(type_choix: :bon)&.pluck(:intitule)&.join(' | ')
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
      json['texte_a_trous'] = texte_a_trous
    end
  end

  def additional_json_fields
    { 'intitule' => transcription_intitule&.ecrit,
      'modalite_reponse' => transcription_modalite_reponse&.ecrit,
      'reponses' => question_reponses }
  end

  def question_reponses
    reponses.map do |reponse|
      reponse.slice(:nom_technique, :intitule, :type_choix)
    end
  end
end
