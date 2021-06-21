# frozen_string_literal: true

require 'generateur_aleatoire'

class Campagne < ApplicationRecord
  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  belongs_to :parcours_type, optional: true

  validates :parcours_type, presence: true, on: :create
  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }

  delegate :structure_code_postal, to: :compte

  auto_strip_attributes :libelle, :code, squish: true

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true

  before_create :initialise_situations, if: :parcours_type_id
  before_save :passe_le_code_en_majuscule

  before_validation :genere_code_unique

  scope :de_la_structure, lambda { |structure|
    joins(:compte).where('comptes.structure_id' => structure)
  }
  scope :par_code, ->(code) { where code: code.upcase }

  def display_name
    libelle
  end

  def questionnaire_pour(situation)
    situations_configurations.find_by(situation: situation)&.questionnaire_utile
  end

  private

  def initialise_situations
    parcours_type.situations_configurations.each do |situation_configuration|
      situations_configurations.build situation_id: situation_configuration.situation_id
    end
  end

  def passe_le_code_en_majuscule
    code&.upcase!
  end

  def genere_code_unique
    return if self[:code].present?
    return if compte.blank?

    loop do
      self[:code] = GenerateurAleatoire.majuscules(3) + structure_code_postal
      break if Campagne.where(code: self[:code]).none?
    end
  end
end
