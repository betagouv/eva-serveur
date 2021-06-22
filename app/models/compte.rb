# frozen_string_literal: true

class Compte < ApplicationRecord
  DELAI_RELANCE_NON_ACTIVATION = 30.days
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable, :registerable
  ROLES = %w[superadmin admin conseiller compte_generique].freeze
  validates :role, inclusion: { in: ROLES }
  enum role: ROLES.zip(ROLES).to_h
  validates :statut_validation, presence: true
  validates_presence_of :nom, :prenom, on: :create
  validate :verifie_dns_email

  auto_strip_attributes :email, :nom, :prenom, :telephone, squish: true

  enum statut_validation: %i[en_attente acceptee refusee], _prefix: :validation

  belongs_to :structure

  accepts_nested_attributes_for :structure

  after_create :programme_email_relance
  after_create :envoie_emails

  def display_name
    [nom_complet, email].reject(&:blank?).join(' - ')
  end

  def nom_complet
    [prenom, nom].reject(&:blank?).join(' ')
  end

  def find_admins
    Compte.where(structure: structure, role: %w[admin superadmin])
  end

  private

  def verifie_dns_email
    return unless email_changed?
    return if Truemail.valid?(email)

    errors.add(:email, :invalid)
  end

  def envoie_emails
    return if superadmin?

    CompteMailer.with(compte: self).nouveau_compte.deliver_later
    find_admins.each do |admin|
      CompteMailer.with(compte: self, compte_admin: admin)
                  .alerte_admin
                  .deliver_later
    end
  end

  def programme_email_relance
    return if superadmin?

    RelanceUtilisateurPourNonActivationJob
      .set(wait: DELAI_RELANCE_NON_ACTIVATION)
      .perform_later(compte: self)
  end
end
