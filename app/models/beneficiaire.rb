# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_many :evaluations, dependent: :destroy
  validates :nom, presence: true
  validates :code_personnel, presence: true, format: { with: /\A[A-Z0-9]+\z/ },
            uniqueness: { case_sensitive: false, conditions: -> { with_deleted } }

  before_validation :genere_code_personnel_unique

  acts_as_paranoid

  scope :par_date_creation_asc, -> { order(created_at: :asc) }
  scope :sauf_pour, ->(id) { where.not(id: id) }

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    nom
  end

  def genere_code_personnel_unique
    return if self[:code_personnel].present?

    loop do
      trois_premiere_lettre_du_nom = nom.parameterize.upcase.gsub(/[^A-Z]/, "").first(3)
      self[:code_personnel] = trois_premiere_lettre_du_nom + GenerateurAleatoire.nombres(4).to_s
      break if Beneficiaire.where(code_personnel: self[:code_personnel]).none?
    end
  end
end
