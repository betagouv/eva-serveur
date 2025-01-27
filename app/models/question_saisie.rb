# frozen_string_literal: true

class QuestionSaisie < Question
  QUESTION_REDACTION = 'redaction_note'
  QUESTION_TYPE = 'QuestionSaisie'

  enum :type_saisie, { redaction: 0, numerique: 1, texte: 2, nombre_avec_virgule: 3 }

  has_many :reponses, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :reponses, allow_destroy: true

  before_save :parametre_nombre_avec_virgule, if: -> { type_saisie == 'nombre_avec_virgule' }

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  def bonnes_reponses
    reponses.where(type_choix: :bon)&.pluck(:intitule)&.join(' | ')
  end

  def parametre_nombre_avec_virgule
    self.reponse_placeholder = '0,00' if reponse_placeholder.blank?
    self.suffix_reponse = '€' if suffix_reponse.blank?
  end

  def self.preload_assocations_pour_as_json
    base_includes_pour_as_json + [:reponses]
  end

  private

  def base_json
    slice(:id, :nom_technique, :suffix_reponse, :description, :metacompetence,
          :demarrage_audio_modalite_reponse, :illustration, :aide, :score).tap do |json|
      json.merge!(base_attributes)
    end
  end

  def base_attributes
    {
      'type' => 'saisie',
      'illustration' => illustration_url,
      'sous_type' => type_saisie,
      'placeholder' => reponse_placeholder,
      'description' => description,
      'texte_a_trous' => texte_a_trous,
      'aide' => aide,
      'max_length' => type_saisie == 'nombre_avec_virgule' ? 6 : nil
    }
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
