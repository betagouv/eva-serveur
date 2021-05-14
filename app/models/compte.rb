# frozen_string_literal: true

class Compte < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :registerable
  ROLES = %w[superadmin admin conseiller compte_generique].freeze
  validates :role, inclusion: { in: ROLES }
  enum role: ROLES.zip(ROLES).to_h
  validates :statut_validation, presence: true
  validates_presence_of :nom, :prenom, on: :create
  validate :verifie_dns_email
  default_scope { order(created_at: :asc) }

  enum statut_validation: %i[en_attente acceptee refusee], _prefix: :validation

  belongs_to :structure

  accepts_nested_attributes_for :structure

  def display_name
    [nom_complet, email].reject(&:blank?).join(' - ')
  end

  def nom_complet
    [prenom, nom].reject(&:blank?).join(' ')
  end

  def nombre_collegue
    Compte.where(structure_id: structure_id)
          .where.not(id: id)
          .count
  end

  private

  def verifie_dns_email
    return unless email_changed?
    return if Truemail.valid?(email)

    errors.add(:email, :invalid)
  end
end
