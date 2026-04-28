class Transcription < ApplicationRecord
  has_one_attached :audio

  AUDIOS_CONTENT_TYPES = [ "audio/mpeg", "audio/mp4" ].freeze

  enum :categorie, { intitule: 0, modalite_reponse: 1, consigne: 2 }
  validates :audio, blob: { content_type: AUDIOS_CONTENT_TYPES }

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
end
