# frozen_string_literal: true

class StructureLocale < Structure
  TYPE_NON_COMMUNIQUE = "non_communique"
  TYPES_STRUCTURES = %w[
    AFPA
    apprentissage
    cap_emploi
    CRIA
    e2c
    GRETA
    mission_locale
    organisme_formation
    orientation_scolaire
    PJJ_UEAJ
    france_travail
    service_insertion_collectivite
    SIAE
    SMA
    autre
  ].freeze

  validates :code_postal, :type_structure, presence: true
  validates :type_structure, inclusion: { in: (TYPES_STRUCTURES + [ TYPE_NON_COMMUNIQUE ]) }
  validates :code_postal, numericality: { only_integer: true }, length: { is: 5 },
                          unless: proc { |s| s.code_postal == TYPE_NON_COMMUNIQUE }

  auto_strip_attributes :code_postal, delete_whitespaces: true

  def display_name
    "#{nom} - #{code_postal}"
  end

  def cible_evaluation
    case type_structure
    when "mission_locale", "orientation_scolaire", "e2c", "SMA"
      "jeunes"
    when "SIAE", "cap_emploi" then "demandeurs d'emploi"
    when "service_insertion_collectivite" then "usagers"
    when "organisme_formation" then "stagiaires"
    else
      "bénéficiaires"
    end
  end
end
