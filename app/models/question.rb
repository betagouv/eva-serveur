# frozen_string_literal: true

class Question < ApplicationRecord
  has_one_attached :illustration

  ILLUSTRATION_CONTENT_TYPES = ['image/png', 'image/jpeg', 'image/webp'].freeze

  attr_accessor :supprimer_illustration, :supprimer_audio_intitule,
                :supprimer_audio_modalite_reponse

  validates :illustration,
            blob: { content_type: ILLUSTRATION_CONTENT_TYPES }

  validates :libelle, :nom_technique, presence: true
  validates :nom_technique, uniqueness: true
  has_many :transcriptions, dependent: :destroy
  has_one :transcription_intitule, lambda {
                                     where(categorie: :intitule)
                                   }, class_name: 'Transcription', dependent: :destroy
  has_one :transcription_modalite_reponse, lambda {
                                             where(categorie: :modalite_reponse)
                                           }, class_name: 'Transcription', dependent: :destroy

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  after_update :supprime_transcription, :supprime_attachment

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end

  def restitue_reponse(reponse)
    reponse
  end

  def supprime_attachment
    illustration.purge_later if supprime_illustration?
    transcriptions.find_each do |t|
      t.audio.purge_later if t.supprime_audio_intitule?(supprimer_audio_intitule)
      t.audio.purge_later if t.supprime_audio_consigne?(supprimer_audio_modalite_reponse)
    end
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

  def supprime_illustration?
    illustration.attached? && supprimer_illustration == '1'
  end
end
