class Structure < ApplicationRecord
  include RechercheSansAccent

  has_ancestry
  acts_as_paranoid
  belongs_to :opco, optional: true

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

  def programme_email_relance
    RelanceStructureSansCampagneJob
      .set(wait: 7.days)
      .perform_later(id)
  end

  private

  def verifie_siret_ou_siren
    return if siret.blank?
    return if [ 14, 9 ].include?(siret.size)

    errors.add(:siret, :invalid)
  end

  def retire_espaces_siret
    return if siret.blank?

    self.siret = siret.gsub(/[[:space:]]/, "")
  end
end
