# frozen_string_literal: true

class Transcription < ApplicationRecord
  has_one_attached :audio

  validate :audio_type

  AUDIOS_CONTENT_TYPES = ['audio/mpeg', 'audio/mp4'].freeze

  enum :categorie, { intitule: 0, modalite_reponse: 1 }

  def audio_type
    return unless audio.attached? && !audio.content_type.in?(%w[audio/mpeg audio/mp4])

    errors.add(:audio, 'doit être un fichier MP3 ou MP4')
    audio.purge
  end

  def audio_url
    return unless audio.attached?

    cdn_for(audio)
  end

  def supprime_audio_intitule?(suppression_valeur)
    intitule? && audio.attached? && suppression_valeur == '1'
  end

  def supprime_audio_consigne?(suppression_valeur)
    modalite_reponse? && audio.attached? &&
      suppression_valeur == '1'
  end

  def complete?
    ecrit.present? && audio&.attached?
  end
end
