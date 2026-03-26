class Structure < ApplicationRecord
  include RechercheSansAccent
  include ValidationSiret
  # Pour les nouvelles structures, on accepte uniquement le SIRET (14 chiffres)
  # Pour les structures existantes, on garde l'ancienne validation (SIREN ou SIRET).
  validate :validation_siret, if: :new_record?
  validate :validation_siret_ou_siren, if: :persisted?

  has_ancestry
  acts_as_paranoid
  belongs_to :opco, optional: true
  has_many :invitations, dependent: :nullify

  alias structure_referente parent
  alias structure_referente= parent=

  attr_accessor :validation_inscription, :current_ability

  validates :nom, presence: true
  validates :nom, uniqueness: {
    case_sensitive: false,
    scope: :code_postal
  }
  validates :siret, numericality: { only_integer: true, allow_blank: true }
  validates :siret, presence: true, on: :create, unless: :superadmin_courant?
  validate :siret_uniqueness, unless: :superadmin_courant?
  validate :ne_peut_pas_supprimer_siret, unless: :superadmin_courant?
  validate :doit_avoir_un_opco, if: :validation_inscription
  validates :email_contact, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :verifie_dns_email_contact
  validates :telephone, format: { with: /\A[\d\s+()\-]+\z/ }, length: { maximum: 20 },
allow_blank: true

  auto_strip_attributes :nom, :email_contact, :telephone, squish: true

  geocoded_by :code_postal, state: :region, params: { countrycodes: "fr" } do |obj, resultats|
    if (resultat = resultats.first)
      obj.region = GeolocHelper.cherche_region(obj.code_postal)
      obj.latitude = resultat.latitude
      obj.longitude = resultat.longitude
    end
  end

  before_validation :verifie_siret_si_necessaire
  after_validation :geocode, if: ->(s) { s.code_postal.present? and s.code_postal_changed? }
  after_create :programme_email_relance

  scope :joins_evaluations_et_groupe, lambda {
    joins("LEFT OUTER JOIN comptes ON structures.id = comptes.structure_id")
      .joins("LEFT OUTER JOIN campagnes ON comptes.id = campagnes.compte_id")
      .joins("LEFT OUTER JOIN evaluations ON campagnes.id = evaluations.campagne_id")
      .group("structures.id")
      .uniq!(:group)
  }
  scope :par_nombre_d_evaluations, lambda { |condition_nb_evaluations|
    joins_evaluations_et_groupe
      .having("COUNT(evaluations.id) #{condition_nb_evaluations}")
  }
  scope :par_derniere_evaluation, lambda { |*condition_date|
    condition_date[0] = "MAX(evaluations.created_at) #{condition_date[0]}"
    joins_evaluations_et_groupe
      .having(*condition_date)
  }

  scope :pas_vraiment_utilisatrices, lambda {
    ids_avec_evaluations = Evaluation.joins(campagne: { compte: :structure })
                                     .select("structures.id")
    ids_avec_campagnes = Campagne.joins(:compte).select("structure_id")
    where.not(id: ids_avec_evaluations).where(id: ids_avec_campagnes)
  }

  scope :sans_campagne, lambda {
    ids = Campagne.joins(:compte).select("structure_id")
    where.not(id: ids)
  }
  scope :non_activees, -> { par_nombre_d_evaluations "BETWEEN 1 AND 3" }
  scope :activees, -> { par_nombre_d_evaluations "> 3" }
  scope :actives, -> { activees.par_derniere_evaluation("> ?", 2.months.ago).uniq!(:group) }
  scope :inactives, lambda {
    activees.par_derniere_evaluation("BETWEEN ? AND ?", 6.months.ago, 2.months.ago).uniq!(:group)
  }
  scope :abandonnistes, -> { activees.par_derniere_evaluation("< ?", 6.months.ago).uniq!(:group) }

  scope :avec_nombre_evaluations_et_date_derniere_evaluation, lambda {
    joins_evaluations_et_groupe
      .select('structures.*,
              COUNT(evaluations.id) AS nombre_evaluations,
              MAX(evaluations.created_at) AS date_derniere_evaluation')
  }

  scope :structures_locales, -> { where(type: StructureLocale.name) }
  scope :avec_meme_siret_que, ->(siret) { where(siret: siret) }
  alias_attribute :display_name, :nom

  def superadmin_courant?
    current_ability&.compte&.superadmin?
  end

  def siret_uniqueness
    return if siret.blank?
    return if errors[:siret].any?

    errors.add(:siret, :taken) if Structure.where.not(id: id).exists?(siret: siret)
  end

  def eva_entreprises?
    false
  end

  def self.ransack_unaccent_attributes
    %w[nom]
  end

  def effectif
    Compte.where(structure: self).count
  end

  def admins
    Compte.where(structure: self, role: Compte::ADMIN_ROLES, statut_validation: :acceptee)
  end

  def programme_email_relance
    RelanceStructureSansCampagneJob
      .set(wait: 7.days)
      .perform_later(id)
  end

  def opco_financeur
    opco if opco&.financeur?
  end

  private
  def verifie_siret_si_necessaire
    return if siret.blank?
    return unless structure_locale?
    return unless doit_verifier_siret?

    statut_initial = statut_siret

    siret_valide = MiseAJourSiret.new(self).verifie_et_met_a_jour

    return if siret_valide || !verification_bloquante?(statut_initial)

    errors.add(:siret, :invalid)
  end

  def structure_locale?
    type == StructureLocale.name || is_a?(StructureLocale)
  end

  def doit_verifier_siret?
    return true if new_record?
    return false unless siret_changed?

    true
  end

  def verification_bloquante?(statut_initial = nil)
    return true if new_record?

    (statut_initial || statut_siret) == true
  end

  def ne_peut_pas_supprimer_siret
    return if anonymise_le.present?
    return if new_record?
    return if siret.present?
    return unless siret_was.present?

    errors.add(:siret, :cannot_be_removed)
  end

  def doit_avoir_un_opco
    return if opco.present?

    errors.add(:opco_id, :must_be_present)
  end

  def verifie_dns_email_contact
    return if email_contact.blank?
    return unless email_contact_changed?
    return if Truemail.valid?(email_contact)

    errors.add(:email_contact, :invalid)
  end
end
