# frozen_string_literal: true

class Question < ApplicationRecord # rubocop:disable Metrics/ClassLength
  CATEGORIE = %i[situation scolarite sante appareils].freeze
  CHAMPS_AUDIO = %i[intitule modalite_reponse consigne].freeze

  has_one_attached :illustration do |attachable|
    attachable.variant :defaut,
                       resize_to_limit: [1080, 566],
                       preprocessed: true,
                       saver: { quality: 90 },
                       format: :jpg
  end

  enum :categorie, CATEGORIE.index_with(&:to_s), prefix: true

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

  scope :n_est_pas_une_sous_consigne, -> { where.not(type: QuestionSousConsigne::QUESTION_TYPE) }
  scope :preload_all_pour_as_json, lambda {
    group_by(&:type).each do |type, questions|
      Question.preload_questions_pour_type(type, questions)
    end

    self
  }

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  after_update :supprime_transcription, :supprime_attachments

  acts_as_paranoid

  def question_data
    QuestionData.find_by(nom_technique: nom_technique)
  end
  delegate :score, :metacompetence, to: :question_data, allow_nil: true

  def display_name
    [categorie, libelle].compact.join(' : ')
  end

  def restitue_reponse(reponse)
    reponse
  end

  def intitule_reponse(reponse)
    reponse
  end

  def reponses_possibles(); end
  def bonnes_reponses(); end

  def suppressions_audios
    { intitule: supprimer_audio_intitule,
      modalite_reponse: supprimer_audio_modalite_reponse,
      consigne: supprimer_audio_consigne }.symbolize_keys
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

  def illustration_url(variant: :defaut)
    return unless illustration.attached?

    if variant
      cdn_for(illustration.variant(variant))
    else
      cdn_for(illustration)
    end
  end

  def self.preload_questions_pour_type(type, questions)
    # Récupérer la classe du type et appeler sa méthode preload_pour_as_json
    klass = type.constantize
    return unless klass.respond_to?(:preload_assocations_pour_as_json)

    ActiveRecord::Associations::Preloader.new(
      records: questions,
      associations: klass.preload_assocations_pour_as_json
    ).call
  end

  def self.non_repondues(noms_techniques_repondues)
    n_est_pas_une_sous_consigne.where.not(nom_technique: noms_techniques_repondues)
  end

  def self.base_includes_pour_as_json
    [
      { illustration_attachment: :blob },
      { transcription_consigne: { audio_attachment: :blob } },
      { transcription_intitule: { audio_attachment: :blob } },
      { transcription_modalite_reponse: { audio_attachment: :blob } }
    ]
  end

  def est_principale?
    nom_technique[2] == 'P'
  end

  def est_un_rattrapage?
    nom_technique[2] == 'R'
  end

  private

  def audio_url
    return transcription_intitule.audio_url if transcription_intitule&.complete?

    transcription_modalite_reponse&.audio_url
  end

  def reject_transcriptions(attributes)
    attributes['audio'].blank? && attributes['ecrit'].blank? if new_record?
  end

  def supprime_attachments
    illustration.purge_later if supprime_illustration?
    transcriptions.find_each do |t|
      CHAMPS_AUDIO.each do |champ|
        t.audio.purge_later if t.supprime_audio?(champ, suppressions_audios[champ])
      end
    end
  end

  def supprime_transcription
    transcriptions.each do |t|
      t.destroy if t.ecrit.blank? && !t.audio.attached?
    end
  end

  def supprime_illustration?
    illustration.attached? &&
      supprimer_illustration == '1' &&
      !nouvelle_illustration?
  end

  def nouvelle_illustration?
    attachment_changes && attachment_changes['illustration'].present?
  end
end
