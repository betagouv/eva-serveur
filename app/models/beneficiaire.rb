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

    self[:code_beneficiaire] = GenerateurCode.new(Beneficiaire, :code_beneficiaire).genere
  end
end
