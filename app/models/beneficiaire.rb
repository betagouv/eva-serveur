require "set"

class Beneficiaire < ApplicationRecord
  include RechercheSansAccent

  NOMBRE_DIGITS_CODE_BENEFICIAIRE = 5

  belongs_to :compte, optional: true
  has_many :evaluations, dependent: :destroy
  validates :nom, presence: true
  validates :code_beneficiaire, presence: true, format: { with: /\A[A-Z0-9]+\z/ },
            uniqueness: { case_sensitive: false, conditions: -> { with_deleted } }

  before_validation :genere_code_beneficiaire_unique

  acts_as_paranoid

  scope :par_date_creation_asc, -> { order(created_at: :asc) }
  scope :sauf_pour, ->(id) { where.not(id: id) }

  delegate :diagnostic, :positionnement, to: :evaluations, prefix: true

  def self.ransack_unaccent_attributes
    %w[nom]
  end

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    "#{nom} - #{code_beneficiaire}"
  end

  def genere_code_beneficiaire_unique
    return if self[:code_beneficiaire].present?
    return if nom.blank?

    self[:code_beneficiaire] = genere_code(nom)
  end

  private

  def genere_code(nom)
    trois_premiere_lettre_du_nom = nom.parameterize.upcase.gsub(/[^A-Z]/, "").first(3).rjust(3, "X")
    codes_existants = Beneficiaire
      .where("code_beneficiaire LIKE ?", "#{trois_premiere_lettre_du_nom}%")
      .pluck(:code_beneficiaire)
    trois_premiere_lettre_du_nom + nouvel_index(codes_existants)
  end

  def nouvel_index(codes_existants)
    indexes_existants = codes_existants.map { |c| c[/\d+/].to_i }.to_set
    nouvel_index = GenerateurAleatoire.nombres(NOMBRE_DIGITS_CODE_BENEFICIAIRE)
    while indexes_existants.include?(nouvel_index) do
      nouvel_index += 1
    end
    nouvel_index.to_s.rjust(NOMBRE_DIGITS_CODE_BENEFICIAIRE, "0")
  end
end
