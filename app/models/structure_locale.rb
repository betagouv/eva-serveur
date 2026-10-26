class StructureLocale < Structure
  include AvecUsage

  attr_accessor :structure_confirmee, :siret_ferme

  scope :pour_inscription, ->(siret) { where(siret: siret).order(:nom, :id) }

  TYPE_NON_COMMUNIQUE = "non_communique"
  TYPES_STRUCTURES = %w[
    AFPA
    apprentissage
    cap_emploi
    service_insertion_collectivite
    CRIA
    e2c
    entreprise
    etablissement_prive
    etablissement_public_sante
    france_travail
    GRETA
    mission_locale
    organisme_formation
    orientation_scolaire
    PJJ_UEAJ
    SMA
    SMV
    SIAE
    autre
  ].freeze

  validates :code_postal, :type_structure, :usage, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + [ TYPE_NON_COMMUNIQUE ]) }
  validates :code_postal, numericality: { only_integer: true }, length: { is: 5 },
                          unless: proc { |s| s.code_postal == TYPE_NON_COMMUNIQUE }

  auto_strip_attributes :code_postal, delete_whitespaces: true

  def code_postal_manquant?
    code_postal.blank? || code_postal == TYPE_NON_COMMUNIQUE
  end

  def affecte_usage_entreprise_si_necessaire
    return unless ENV["ACTIVE_EVAPRO"].present?
    return unless type_structure == "entreprise"
    return if evapro?

    self.usage = AvecUsage::USAGE_EVAPRO
  end

  def display_name
    "#{nom} - #{code_postal}"
  end

  def evapro?
    usage == AvecUsage::USAGE_EVAPRO
  end
  alias_method :eva_entreprises?, :evapro?

  def metabase_dashboard
    23
  end

  def metabase_query_params
    { "id" => [ id ] }
  end
end
