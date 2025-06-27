# frozen_string_literal: true

class Compte < ApplicationRecord
  DELAI_RELANCE_NON_ACTIVATION = 30.days
  ROLES = %w[superadmin admin charge_mission_regionale conseiller compte_generique].freeze
  ROLES_STRUCTURE = %w[admin conseiller].freeze
  ADMIN_ROLES = %w[superadmin admin compte_generique].freeze
  ANLCI_ROLES = %w[superadmin charge_mission_regionale].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable, :registerable, :confirmable

  acts_as_paranoid

  include Comptes::EnvoieEmails

  validates :role, inclusion: { in: ROLES }
  enum :role, ROLES.zip(ROLES).to_h
  validates :statut_validation, presence: true
  validate :verifie_etat_si_structure_manquante
  validates :nom, :prenom, presence: { on: :create }
  validate :verifie_dns_email, :structure_a_un_admin
  validates :email, uniqueness: { case_sensitive: false }
  validates_with PasswordValidator, fields: [ :password ]

  auto_strip_attributes :email, :nom, :prenom, :telephone, squish: true

  enum :statut_validation, { en_attente: 0, acceptee: 1, refusee: 2 }, prefix: :validation

  delegate :code_postal, to: :structure, prefix: true

  belongs_to :structure, optional: true

  accepts_nested_attributes_for :structure

  scope :de_la_structure, ->(structure) { where(structure: structure) }

  def display_name
    nom_complet.presence || email
  end

  def nom_complet
    [ prenom, nom ].compact_blank.join(" ")
  end

  def find_admins
    Compte.where(structure: structure, role: ADMIN_ROLES, statut_validation: :acceptee)
  end

  def anlci?
    ANLCI_ROLES.include?(role)
  end

  def au_moins_admin?
    ADMIN_ROLES.include?(role)
  end

  def assigne_role_admin_si_pas_d_admin
    return if autres_admins?

    self.role = :admin
    self.statut_validation = :acceptee
  end

  def email_non_confirme?
    !confirmed? || unconfirmed_email.present?
  end

  def email_a_confirmer
    return if confirmed? && unconfirmed_email.blank?

    unconfirmed_email.presence || email
  end

  def rejoindre_structure(structure)
    self.structure = structure
    self.statut_validation = :en_attente
    self.role = :conseiller

    assigne_role_admin_si_pas_d_admin
    save
  end

  private

  def verifie_etat_si_structure_manquante
    return if structure.present?

    unless validation_en_attente?
      errors.add(:statut_validation,
                 :doit_etre_en_attente_si_structure_vide)
    end
    errors.add(:role, :doit_etre_conseiller_si_structure_vide) unless conseiller?
  end

  def verifie_dns_email
    return if email.blank?
    return unless email_changed?
    return if Truemail.valid?(email)

    errors.add(:email, :invalid)
  end

  def structure_a_un_admin
    return if structure.nil?
    return if au_moins_admin? && !validation_refusee?
    return if autres_admins?

    if au_moins_admin? && validation_refusee?
      errors.add(:statut_validation, :structure_doit_avoir_un_admin)
    else
      errors.add(:role, :structure_doit_avoir_un_admin)
    end
  end

  def autres_admins?
    find_admins.where.not(id: id).count >= 1
  end
end
