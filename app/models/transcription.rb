# frozen_string_literal: true

class Transcription < ApplicationRecord
  has_one_attached :audio

  validate :audio_type

  enum categorie: { intitule: 0, modalite_reponse: 1 }

  def audio_type
    return unless audio.attached? && !audio.content_type.in?(%w[audio/mpeg audio/mp4])

    errors.add(:audio, 'doit être un fichier MP3 ou MP4')
    audio.purge
  end
end
