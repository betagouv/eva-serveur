# frozen_string_literal: true

class Question < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_one_attached :illustration do |attachable|
    attachable.variant :defaut,
                       resize_to_limit: [1080, 566],
                       preprocessed: true,
                       saver: { quality: 90 },
                       format: :jpg
  end

  enum :metacompetence, Metacompetence::METACOMPETENCES

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

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  AUDIO_TYPES = %i[intitule modalite_reponse consigne].freeze
  INTERACTION_TYPES = {
    QuestionQcm::QUESTION_TYPE => 'qcm',
    QuestionClicDansImage::QUESTION_TYPE => 'clic dans image',
    QuestionGlisserDeposer::QUESTION_TYPE => 'glisser deposer',
    QuestionSousConsigne::QUESTION_TYPE => 'sous consigne',
    QuestionSaisie::QUESTION_TYPE => 'saisie',
    QuestionClicDansTexte::QUESTION_TYPE => 'clic dans texte'
  }.freeze

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

  def illustration_url(variant: :defaut)
    return unless illustration.attached?

    if variant
      cdn_for(illustration.variant(variant))
    else
      cdn_for(illustration)
    end
  end

  def interaction
    INTERACTION_TYPES[type]
  end

  def saisie?
    type == QuestionSaisie::QUESTION_TYPE
  end

  def qcm?
    type == QuestionQcm::QUESTION_TYPE
  end

  def glisser_deposer?
    type == QuestionGlisserDeposer::QUESTION_TYPE
  end

  def sous_consigne?
    type == QuestionSousConsigne::QUESTION_TYPE
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

  def supprime_transcription
    transcriptions.each do |t|
      t.destroy if t.ecrit.blank? && !t.audio.attached?
    end
  end

  def supprime_illustration?
    illustration.attached? && supprimer_illustration == '1'
  end
end
