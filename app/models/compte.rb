# frozen_string_literal: true

class Compte < ApplicationRecord
  ADMINISTRATEUR = 'administrateur'
  ORGANISATION = 'organisation'
  ROLES = [ADMINISTRATEUR, ORGANISATION].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :omniauthable,
         :recoverable, :rememberable, :validatable
  validates :role, inclusion: { in: ROLES }, presence: true
  default_scope { order(created_at: :asc) }

  def display_name
    email
  end

  def administrateur?
    role == ADMINISTRATEUR
  end

  def self.from_omniauth(auth)
    compte = where(email: auth.info.email).first || new
    compte.password = SecureRandom.hex(64) unless compte.persisted?
    compte.update(
      fournisseur: auth.provider,
      fournisseur_uid: auth.uid,
      email: auth.info.email,
      role: ADMINISTRATEUR
    )
    compte
  end
end
