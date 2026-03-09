# frozen_string_literal: true

class Invitation < ApplicationRecord
  STATUTS = %w[en_cours acceptee annulee].freeze
  ROLES = Compte::ROLES_STRUCTURE

  belongs_to :structure
  belongs_to :invitant, class_name: "Compte"
  belongs_to :compte, optional: true

  validates :token, presence: true, uniqueness: true
  validates :statut, inclusion: { in: STATUTS }
  validates :role, inclusion: { in: ROLES }

  before_validation :generate_token, on: :create

  scope :en_cours, -> { where(statut: "en_cours") }
  scope :acceptee, -> { where(statut: "acceptee") }
  scope :annulee, -> { where(statut: "annulee") }

  def utilisable?
    statut == "en_cours"
  end

  def annuler!
    update!(statut: "annulee")
  end

  def marquer_acceptee!(compte)
    update!(statut: "acceptee", compte: compte)
  end

  def role_pour_compte
    role.presence || "conseiller"
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end
end
