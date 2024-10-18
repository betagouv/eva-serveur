# frozen_string_literal: true

class Transcription < ApplicationRecord
  has_one_attached :audio

  validate :audio_type

  AUDIOS_CONTENT_TYPES = ['audio/mpeg', 'audio/mp4'].freeze

  enum :categorie, { intitule: 0, modalite_reponse: 1, consigne: 2 }

  def audio_type
    return unless audio.attached? && !audio.content_type.in?(AUDIOS_CONTENT_TYPES)

    errors.add(:audio, 'doit être un fichier MP3 ou MP4')
    audio.purge
  end

  def audio_url
    return unless audio.attached?

    cdn_for(audio)
  end

  def supprime_audio(type, suppression_valeur)
    audio.purge_later if send("#{type}?") && audio.attached? && suppression_valeur == '1'
  end

  def complete?
    ecrit.present? && audio&.attached?
  end
end
