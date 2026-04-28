class Transcription < ApplicationRecord
  has_one_attached :audio

  AUDIOS_CONTENT_TYPES = [ "audio/mpeg", "audio/mp4" ].freeze
  AUDIO_EXTENSIONS = %w[.mp3 .mp4].freeze

  enum :categorie, { intitule: 0, modalite_reponse: 1, consigne: 2 }
  validates :audio, blob: { content_type: AUDIOS_CONTENT_TYPES }
  validate :audio_extension
  def audio_url
    cdn_for(audio)
  end

  def supprime_audio?(champ, suppression_valeur)
    send("#{champ}?") &&
      audio.attached? &&
      suppression_valeur == "1" &&
      !nouveau_audio?
  end

  def nouveau_audio?
    attachment_changes && attachment_changes["audio"].present?
  end

  def complete?
    ecrit.present? && audio&.attached?
  end

  def audio_extension
    return unless audio.attached?
    extension = audio.blob.filename.extension_with_delimiter&.downcase

    return if extension.in?(AUDIO_EXTENSIONS)
    errors.add(:audio, :invalid_extension)
  end
end
