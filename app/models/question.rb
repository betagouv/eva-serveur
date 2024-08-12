# frozen_string_literal: true

class Question < ApplicationRecord
  has_one_attached :illustration
  validates :illustration,
            blob: { content_type: ['image/png', 'image/jpeg', 'image/webp'] }

  validates :libelle, :nom_technique, presence: true
  has_many :transcriptions, dependent: :destroy

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  after_update :supprime_transcription

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end

  def transcription_ecrite_pour(categorie)
    transcriptions.find_by(categorie: categorie)&.ecrit
  end

  def transcription_pour(categorie)
    transcriptions.find_by(categorie: categorie)
  end

  private

  def reject_transcriptions(attributes)
    attributes['audio'].blank? && attributes['ecrit'].blank? if new_record?
  end

  def supprime_transcription
    transcriptions.each do |t|
      t.destroy if t.ecrit.blank? && !t.audio.attached?
    end
  end
end
