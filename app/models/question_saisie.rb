# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  enum :type_saisie, { redaction: 0, numerique: 1 }
  has_many :transcriptions, dependent: :destroy, foreign_key: :question_id

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  def as_json(_options = nil)
    json = slice(:id, :intitule, :nom_technique, :suffix_reponse, :description)
    json['type'] = 'saisie'
    json['sous_type'] = type_saisie
    json['placeholder'] = reponse_placeholder
    json
  end

  private

  def reject_transcriptions(attributes)
    attributes['audio'].blank? && attributes['ecrit'].blank? && new_record?
  end
end
