# frozen_string_literal: true

class Choix < ApplicationRecord
  has_one_attached :illustration

  validates :illustration,
            blob: { content_type: ApplicationController.helpers.illustration_content_types }

  validates :intitule, :type_choix, :nom_technique, presence: true
  enum :type_choix, { bon: 0, mauvais: 1, abstention: 2 }
  has_one_attached :audio

  validate :audio_type

  acts_as_list scope: :question_id

  def as_json(_options = nil)
    slice(:id, :intitule, :type_choix, :nom_technique)
  end

  def audio_type
    return unless audio.attached? && !audio.content_type.in?(%w[audio/mpeg audio/mp4])

    errors.add(:audio, 'doit être un fichier MP3 ou MP4')
    audio.purge
  end
end
