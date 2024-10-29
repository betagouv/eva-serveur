# frozen_string_literal: true

class Question < ApplicationRecord
  has_one_attached :illustration

  attr_accessor :supprimer_illustration, :supprimer_audio_intitule,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne

  validates :illustration,
            blob: { content_type: ApplicationController.helpers.illustration_content_types }

  validates :libelle, :nom_technique, presence: true
  validates :nom_technique, uniqueness: true
  has_many :transcriptions, dependent: :destroy
  has_one :transcription_intitule, lambda {
                                     where(categorie: :intitule)
                                   }, class_name: 'Transcription', dependent: :destroy
  has_one :transcription_modalite_reponse, lambda {
                                             where(categorie: :modalite_reponse)
                                           }, class_name: 'Transcription', dependent: :destroy
  has_one :transcription_consigne, lambda {
    where(categorie: :consigne)
  }, class_name: 'Transcription', dependent: :destroy

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  AUDIO_TYPES = %i[intitule modalite_reponse consigne].freeze

  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  after_update :supprime_transcription, :supprime_attachment

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end

  def restitue_reponse(reponse)
    reponse
  end

  def suppressions_audios
    { intitule: supprimer_audio_intitule,
      modalite_reponse: supprimer_audio_modalite_reponse,
      consigne: supprimer_audio_consigne }.symbolize_keys
  end

  def supprime_attachment
    illustration.purge_later if supprime_illustration?
    transcriptions.find_each do |t|
      AUDIO_TYPES.each do |type|
        t.supprime_audio(type, suppressions_audios[type])
      end
    end
  end

  def json_audio_fields
    json = { 'consigne_audio' => transcription_consigne&.audio_url }
    json['audio_url'] = audio_url
    unless transcription_intitule&.complete?
      json['intitule_audio'] =
        transcription_intitule&.audio_url
    end
    json
  end

  def audio_url
    return transcription_intitule.audio_url if transcription_intitule&.complete?

    transcription_modalite_reponse&.audio_url
  end

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
