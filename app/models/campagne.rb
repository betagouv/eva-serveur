# frozen_string_literal: true

class Campagne < ApplicationRecord
  SITUATIONS_PAR_DEFAUT = %i[
    bienvenue
    maintenance
    inventaire
    livraison
    tri
    controle
    securite
    objets_trouves
  ].freeze

  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  has_many :situations, through: :situations_configurations
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  default_scope { order(created_at: :asc) }

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true
  before_validation :genere_code_unique

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true
  accepts_nested_attributes_for :compte

  attr_accessor :initialise_situations

  before_create :initialise_situations_par_defaut, if: :initialise_situations

  def display_name
    libelle
  end

  private

  def initialise_situations_par_defaut
    SITUATIONS_PAR_DEFAUT.each do |nom_technique|
      situation = Situation.find_by nom_technique: nom_technique
      situations << situation unless situation.nil?
    end
  end

  def genere_code_unique
    return if self[:code].present?

    loop do
      self[:code] = SecureRandom.hex 3
      break if Campagne.where(code: self[:code]).none?
    end
  end
end
