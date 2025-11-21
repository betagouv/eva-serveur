class Structure < ApplicationRecord
  include RechercheSansAccent

  has_ancestry
  acts_as_paranoid
  has_many :structure_opcos, dependent: :destroy
  has_many :opcos, through: :structure_opcos

  alias structure_referente parent
  alias structure_referente= parent=

  validates :nom, presence: true
  validates :nom, uniqueness: {
    case_sensitive: false,
    scope: :code_postal
  }
  validates :siret, numericality: { only_integer: true, allow_blank: true }
  validates :siret, presence: true, on: :create
  validate :verifie_siret_ou_siren

  auto_strip_attributes :nom, squish: true

  geocoded_by :code_postal, state: :region, params: { countrycodes: "fr" } do |obj, resultats|
    if (resultat = resultats.first)
      obj.region = GeolocHelper.cherche_region(obj.code_postal)
      obj.latitude = resultat.latitude
      obj.longitude = resultat.longitude
    end
  end

  before_validation :retire_espaces_siret
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

  alias_attribute :display_name, :nom

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

  private

  def verifie_siret_ou_siren
    return if siret.blank?

    # Pour les nouvelles structures, on accepte uniquement le SIRET (14 chiffres)
    # On ne va faire de validation de l'algo de Luhn
    # On fera une vérification plus tard avec un point d'api
    # La poste ne respecte pas l'algo de luhn pour son siret.
    if new_record?
      return if siret.size == 14

      errors.add(:siret, :invalid)
    else
      # Pour les structures existantes, on garde l'ancienne validation (SIREN ou SIRET)
      return if [ 14, 9 ].include?(siret.size)

      errors.add(:siret, :invalid)
    end
  end

  def retire_espaces_siret
    return if siret.blank?

    self.siret = siret.gsub(/[[:space:]]/, "")
  end

  def verifie_siret_si_necessaire
    return if siret.blank?
    return unless doit_verifier_siret?

    statut_initial = statut_siret

    mise_a_jour = MiseAJourSiret.new(self)
    siret_valide = mise_a_jour.verifie_et_met_a_jour

    return if siret_valide || !verification_bloquante?(statut_initial)

    errors.add(:siret, :invalid)
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
end
