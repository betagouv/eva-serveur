class Compte < ApplicationRecord
  include EtapeInscription
  include AvecUsage
  include ValidationSiret
  validation_siret_column :siret_pro_connect
  validate :validation_siret

  attr_accessor :structure_confirmee, :force_deplacement_structure

  DELAI_RELANCE_NON_ACTIVATION = 30.days
  ROLES = %w[conseiller admin charge_mission_regionale superadmin compte_generique].freeze
  AIDES_ROLES = {
    "conseiller" => I18n.t("activerecord.attributes.compte.aide_roles.conseiller"),
    "admin" => I18n.t("activerecord.attributes.compte.aide_roles.admin")
  }.freeze
  ROLES_STRUCTURE = %w[conseiller admin].freeze
  ADMIN_ROLES = %w[superadmin admin compte_generique].freeze
  ANLCI_ROLES = %w[superadmin charge_mission_regionale].freeze

  FONCTIONS = [
    "assistante_ou_assistant_social",
    "chargee_ou_charge_de_formation",
    "cheffe_ou_chef_de_projet",
    "conseillere_ou_conseiller_emploi_formation_insertion",
    "consultante_ou_consultant",
    "coordinatrice_ou_coordinateur_pedagogique",
    "directrice_ou_directeur",
    "educatrice_ou_educateur",
    "enseignante_ou_enseignant_de_l_education_nationale",
    "formatrice_ou_formateur",
    "psychologue_ou_medecin_du_travail",
    "referente_ou_referent_handicap",
    "responsable_conseillere_ou_conseiller_rh",
    "responsable_conseillere_ou_conseiller_rse",
    "volontaire_service_civique",
    "autre"
  ].freeze

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
  validates :nom, :prenom, presence: { on: :create, unless: :peut_sauter_presence_identite? }
  validates :nom, :prenom, presence: { on: :informations_compte,
                                        unless: :peut_sauter_presence_identite? }
  validate :verifie_dns_email, :structure_a_un_admin
  validate :structure_de_depart_a_un_admin, unless: :force_deplacement_structure
  validates :email, uniqueness: { case_sensitive: false }
  validates_with PasswordValidator, fields: [ :password ]
  validates :fonction, inclusion: { in: FONCTIONS }, allow_blank: true

  auto_strip_attributes :email, :nom, :prenom, :telephone, squish: true

  enum :statut_validation, { en_attente: 0, acceptee: 1, refusee: 2 }, prefix: :validation

  delegate :code_postal, to: :structure, prefix: true

  belongs_to :structure, optional: true

  accepts_nested_attributes_for :structure

  scope :de_la_structure, ->(structure) { structure ? where(structure: structure) : none }

  def display_name
    nom_complet.presence || email
  end

  def nom_complet
    [ prenom, nom ].compact_blank.join(" ")
  end

  def anlci?
    ANLCI_ROLES.include?(role)
  end

  def administratif?
    structure.instance_of?(StructureAdministrative)
  end

  def utilisateur_entreprise?
    !!structure&.eva_entreprises?
  end

  def au_moins_admin?
    ADMIN_ROLES.include?(role)
  end

  def assigne_role_admin_si_pas_d_admin
    return if autres_admins?(structure)

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

  def peut_sauter_presence_identite?
    etape_inscription_preinscription?
  end

  def structure_a_un_admin
    return if structure.nil?
    return if au_moins_admin? && !validation_refusee?
    return if autres_admins?(structure)

    ajoute_erreur_admin
  end

  def structure_de_depart_a_un_admin
    return unless quitte_structure?

    ancienne_structure = Structure.find_by(id: structure_id_was)
    return if autres_admins?(ancienne_structure)

    errors.add(:structure, :refus_depart_structure, nom_structure: ancienne_structure.nom)
  end

  def quitte_structure?
    persisted? && structure_id_changed? && structure_id_was.present?
  end

  def autres_admins?(structure)
    structure.admins.where.not(id: id).count >= 1
  end

  def ajoute_erreur_admin
    if au_moins_admin? && validation_refusee?
      errors.add(:statut_validation, :structure_doit_avoir_un_admin, nom_structure: structure.nom)
    else
      errors.add(:role, :structure_doit_avoir_un_admin, nom_structure: structure.nom)
    end
  end
end
