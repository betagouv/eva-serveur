# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_many :evaluations, dependent: :destroy
  validates :nom, presence: true
  validates :code, presence: true, format: { with: /\A[A-Z0-9]+\z/ },
                   uniqueness: { case_sensitive: false, conditions: -> { with_deleted } }

  before_validation :genere_code_unique

  acts_as_paranoid

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    nom
  end

  def genere_code_unique
    return if self[:code].present?

    loop do
      trois_premiere_lettre_du_nom = nom.parameterize.upcase.gsub(/[^A-Z]/, "").first(3)
      self[:code] = trois_premiere_lettre_du_nom + GenerateurAleatoire.nombres(4).to_s
      break if Beneficiaire.where(code: self[:code]).none?
    end
  end
end
