# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  enum :type_saisie, { redaction: 0, numerique: 1 }

  has_one :bonne_reponse, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy

  accepts_nested_attributes_for :bonne_reponse, allow_destroy: true

  def as_json(_options = nil)
    json = slice(:id, :nom_technique, :suffix_reponse, :description)
    json['type'] = 'saisie'
    json['intitule'] = transcription_intitule&.ecrit
    json['sous_type'] = type_saisie
    json['placeholder'] = reponse_placeholder
    json['reponse'] = bonne_reponse&.intitule
    json
  end
end
