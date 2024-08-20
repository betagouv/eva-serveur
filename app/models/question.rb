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

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  after_update :supprime_transcription, :supprime_attachment_sur_requete

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

  def restitue_reponse(reponse)
    reponse
  end

  def supprime_attachment_sur_requete
    illustration.purge if supprime_illustration?(illustration)
    transcriptions.find_each do |t|
      t.audio.purge if supprime_audio_intitule?(t)
      t.audio.purge if supprime_audio_consigne?(t)
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

  def supprime_audio_intitule?(transcription)
    transcription.intitule? && transcription.audio.attached? && supprimer_audio_intitule == '1'
  end

  def supprime_audio_consigne?(transcription)
    transcription.modalite_reponse? && transcription.audio.attached? &&
      supprimer_audio_modalite_reponse == '1'
  end

  def supprime_illustration?(illustration)
    illustration.attached? && supprimer_illustration == '1'
  end
end
