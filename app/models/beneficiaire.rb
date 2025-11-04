class Beneficiaire < ApplicationRecord
  include RechercheSansAccent

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

    loop do
      self[:code_beneficiaire] = genere_code_a_partir_du_nom
      break if Beneficiaire.where(code_beneficiaire: self[:code_beneficiaire]).none?
    end
  end

  private

  def genere_code_a_partir_du_nom
    trois_premiere_lettre_du_nom = nom.parameterize.upcase.gsub(/[^A-Z]/, "").first(3)
    trois_premiere_lettre_du_nom + GenerateurAleatoire.nombres(4).to_s
  end
end
