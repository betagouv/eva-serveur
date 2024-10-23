# frozen_string_literal: true

require 'generateur_aleatoire'

class Campagne < ApplicationRecord
  PERSONNALISATION = %w[plan_de_la_ville autopositionnement redaction].freeze

  acts_as_paranoid

  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  has_many :evaluations, dependent: :destroy
  belongs_to :compte
  belongs_to :parcours_type, optional: true

  validates :type_programme, presence: true, on: :create
  validates :parcours_type, presence: true, on: :create
  validates :libelle, presence: true
  validates :code, presence: true, format: { with: /\A[A-Z0-9]+\z/ },
                   uniqueness: { case_sensitive: false, conditions: -> { with_deleted } }
  validates_associated :situations_configurations
  delegate :structure_code_postal, to: :compte
  auto_strip_attributes :libelle, :code, squish: true
  accepts_nested_attributes_for :situations_configurations, allow_destroy: true

  before_validation :genere_code_unique
  before_create :initialise_situations, if: :parcours_type_id
  attr_accessor :options_personnalisation, :type_programme

  scope :de_la_structure, lambda { |structure|
    joins(:compte)
      .avec_nombre_evaluations_et_derniere_evaluation
      .where('comptes.structure_id' => structure)
      .order('date_derniere_evaluation DESC NULLS LAST')
  }
  scope :avec_nombre_evaluations_et_derniere_evaluation, lambda {
    left_outer_joins(:evaluations)
      .group(:id)
      .select('campagnes.*,
              COUNT(evaluations.id) AS nombre_evaluations,
              MAX(evaluations.created_at) AS date_derniere_evaluation')
  }
  scope :par_code, ->(code) { where code: code.upcase }
  scope :avec_situation, lambda { |situation|
    joins(:situations_configurations).where(situations_configurations: {
                                              situation_id: situation&.id
                                            })
  }

  def display_name
    libelle
  end

  def questionnaire_pour(situation)
    sc = situations_configurations.find_by(situation: situation)
    sc.present? ? sc.questionnaire_utile : situation.questionnaire
  end

  def avec_competences_transversales?
    configuration_inclus?(&:competences_transversales?)
  end

  def avec_numeratie?
    configuration_inclus?(&:numeratie?)
  end

  def avec_pre_positionnement?
    configuration_inclus?(&:pre_positionnement?)
  end

  def avec_litteratie?
    configuration_inclus?(&:litteratie?)
  end

  def genere_code_unique
    return if self[:code].present?
    return if compte.blank?

    loop do
      self[:code] = GenerateurAleatoire.majuscules(3) + structure_code_postal
      break if Campagne.where(code: self[:code]).none?
    end
  end

  private

  def configuration_inclus?
    situations_configurations.any? do |configuration|
      yield(configuration.situation)
    end
  end

  def initialise_situations
    initialise_situations_optionnelles
    # rubocop:disable Rails/FindEach
    parcours_type.situations_configurations
                 .includes(situation: :questionnaire)
                 .each do |situation_configuration|
      # rubocop:enable Rails/FindEach
      construit_situation_configuration(situation_configuration)
    end
  end

  def initialise_situations_optionnelles
    return if options_personnalisation.blank?
    return unless options_personnalisation.include? Situation::PLAN_DE_LA_VILLE

    situation = Situation.find_by nom_technique: Situation::PLAN_DE_LA_VILLE

    situations_configurations.build situation_id: situation.id
  end

  def construit_situation_configuration(situation_configuration)
    situations_configurations.build situation_id: situation_configuration.situation_id,
                                    questionnaire_id: questionnaire_id(situation_configuration)
  end

  def questionnaire_id(situation_configuration)
    if situation_configuration.livraison_sans_redaction? && option_incluse?('redaction')
      Questionnaire.livraison_avec_redaction.id
    elsif situation_configuration.bienvenue? && option_incluse?('autopositionnement')
      Questionnaire.bienvenue_avec_autopositionnement.id
    else
      situation_configuration.questionnaire_id
    end
  end

  def option_incluse?(option)
    options_personnalisation.present? && options_personnalisation.include?(option)
  end
end
