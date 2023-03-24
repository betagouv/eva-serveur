# frozen_string_literal: true

require 'generateur_aleatoire'

class Campagne < ApplicationRecord
  SITUATIONS_COMPETENCES_TRANSVERSALES = %w[controle inventaire securite tri].freeze
  SITUATIONS_PRE_POSITIONNEMENT = %w[maintenance livraison objets_trouves].freeze
  SITUATIONS_POSITIONNEMENT = %w[cafe_de_la_place].freeze
  PERSONNALISATION = %w[plan_de_la_ville bienvenue livraison].freeze

  acts_as_paranoid

  has_many :situations_configurations, lambda {
                                         order(position: :asc)
                                       }, dependent: :destroy

  has_many :evaluations, dependent: :restrict_with_error
  belongs_to :compte
  belongs_to :parcours_type, optional: true

  validates :type_programme, presence: true, on: :create
  validates :parcours_type, presence: true, on: :create
  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[A-Z0-9]+\z/ }
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
  }
  scope :avec_nombre_evaluations_et_derniere_evaluation, lambda {
    left_outer_joins(:evaluations)
      .group('id')
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
    situations_configurations.find_by(situation: situation)&.questionnaire_utile
  end

  def avec_competences_transversales?
    configuration_inclus?(SITUATIONS_COMPETENCES_TRANSVERSALES)
  end

  def avec_positionnement?
    configuration_inclus?(SITUATIONS_POSITIONNEMENT)
  end

  def avec_pre_positionnement?
    configuration_inclus?(SITUATIONS_PRE_POSITIONNEMENT)
  end

  private

  def configuration_inclus?(situations)
    situations_configurations.any? do |configuration|
      situations.include?(configuration.situation.nom_technique)
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

    options_personnalisation.compact_blank.each do |situation_optionnelle|
      situation = Situation.find_by nom_technique: situation_optionnelle
      next if situation.blank?
      next if situation.nom_technique == 'livraison'

      situations_configurations.build situation_id: situation.id
    end
  end

  def genere_code_unique
    return if self[:code].present?
    return if compte.blank?

    loop do
      self[:code] = GenerateurAleatoire.majuscules(3) + structure_code_postal
      break if Campagne.where(code: self[:code]).none?
    end
  end

  def construit_situation_configuration(situation_configuration)
    livraison_sans_redaction = situation_configuration.livraison_sans_redaction?
    questionnaire_id = if inclus_expression_ecrite? && livraison_sans_redaction
                         Questionnaire.livraison_avec_redaction.id
                       else
                         situation_configuration.questionnaire_id
                       end
    situations_configurations.build situation_id: situation_configuration.situation_id,
                                    questionnaire_id: questionnaire_id
  end

  def inclus_expression_ecrite?
    return false if options_personnalisation.nil?

    options_personnalisation.include? 'livraison'
  end
end
