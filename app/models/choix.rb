class Choix < ApplicationRecord
  has_one_attached :illustration

  validates :illustration,
            blob: { content_type: ApplicationController.helpers.illustration_content_types }

  validates :type_choix, :nom_technique, presence: true
  validates :nom_technique, uniqueness: { scope: :question_id }
  enum :type_choix, { bon: 0, mauvais: 1, abstention: 2, bonus: 3, acceptable: 4 }
  has_one_attached :audio

  validate :audio_type
  validate :score_objet_json

  AUDIOS_CONTENT_TYPES = [ "audio/mpeg", "audio/mp4" ].freeze

  acts_as_list scope: :question_id

  def as_json(_options = nil)
    slice(:id, :intitule, :type_choix, :nom_technique, :score)
  end

  def score=(valeur)
    @score_saisi_invalide = nil
    valeur = valeur.presence && JSON.parse(valeur) if valeur.is_a?(String)
    super
  rescue JSON::ParserError
    @score_saisi_invalide = valeur
    super(nil)
  end

  def score_json
    @score_saisi_invalide || score&.to_json
  end

  def score_objet_json
    return unless @score_saisi_invalide || !(score.nil? || score.is_a?(Hash))

    errors.add(:score, :invalid_json)
  end

  def audio_type
    return unless audio.attached? && !audio.content_type.in?(AUDIOS_CONTENT_TYPES)

    errors.add(:audio, "doit être un fichier MP3 ou MP4")
    audio.purge
  end

  def audio_url
    cdn_for(audio)
  end

  def illustration_url
    cdn_for(illustration)
  end
end
