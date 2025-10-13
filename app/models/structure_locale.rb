class StructureLocale < Structure
  TYPE_NON_COMMUNIQUE = "non_communique"
  TYPES_STRUCTURES = %w[
    AFPA
    apprentissage
    cap_emploi
    CRIA
    e2c
    entreprise
    GRETA
    mission_locale
    organisme_formation
    orientation_scolaire
    PJJ_UEAJ
    france_travail
    service_insertion_collectivite
    SIAE
    SMA
    SMV
    autre
  ].freeze

  CIBLE_EVALUATION = {
    AFPA: "stagiaires",
    GRETA: "stagiaires",
    PJJ_UEAJ: "jeunes",
    SIAE: "salarié(e)s",
    SMA: "jeunes",
    SMV: "jeunes",
    apprentissage: "stagiaires",
    cap_emploi: "demandeurs d'emploi",
    e2c: "jeunes",
    entreprise: "salarié(e)s",
    france_travail: "demandeurs d'emploi",
    mission_locale: "jeunes",
    organisme_formation: "stagiaires",
    orientation_scolaire: "jeunes",
    service_insertion_collectivite: "usagers"
  }.freeze

  USAGE = [ "Eva: bénéficiaires", "Eva: entreprises" ].freeze

  validates :code_postal, :type_structure, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + [ TYPE_NON_COMMUNIQUE ]) }
  validates :code_postal, numericality: { only_integer: true }, length: { is: 5 },
                          unless: proc { |s| s.code_postal == TYPE_NON_COMMUNIQUE }
  validates :usage, inclusion: { in: USAGE }

  auto_strip_attributes :code_postal, delete_whitespaces: true

  def display_name
    "#{nom} - #{code_postal}"
  end

  def cible_evaluation
    CIBLE_EVALUATION[type_structure&.to_sym] || "bénéficiaires"
  end

  def eva_entreprises?
    type_structure == "entreprise" && usage == "Eva: entreprises"
  end
end
