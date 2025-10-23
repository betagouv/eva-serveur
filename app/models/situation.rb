class Situation < ApplicationRecord
  include AvecNomTechnique

  BIENVENUE = "bienvenue"
  CAFE_DE_LA_PLACE = "cafe_de_la_place"
  PLAN_DE_LA_VILLE = "plan_de_la_ville"
  PLACE_DU_MARCHE = "place_du_marche"
  DIAG_RISQUES_ENTREPRISE = "diag_risques_entreprise"
  EVALUATION_IMPACT_GENERAL = "evaluation_impact_general"
  COULEURS_BORDURES = [ "#6E85FD", "#82ABE8", "#8FC6DA", "#9FD9C9", "#ABCE8F", "#DFBC78", "#FBAF55",
                       "#FD8554", "#FD5965", "#FD586D" ].freeze

  SITUATIONS_COMPETENCES_TRANSVERSALES = %w[controle inventaire securite tri].freeze
  SITUATIONS_DIAGNOSTIC = %w[maintenance livraison objets_trouves].freeze
  SITUATIONS_NUMERATIE = %w[place_du_marche].freeze
  SITUATIONS_LITTERATIE = %w[cafe_de_la_place].freeze
  SITUATIONS_POSITIONNEMENT = SITUATIONS_NUMERATIE + SITUATIONS_LITTERATIE

  validates :libelle, presence: true
  validate :nom_technique_ne_doit_pas_contenir_de_tirets

  has_one_attached :illustration
  belongs_to :questionnaire, optional: true
  belongs_to :questionnaire_entrainement, optional: true, class_name: "Questionnaire"

  delegate :livraison_sans_redaction?, to: :questionnaire, allow_nil: true

  acts_as_paranoid

  def display_name
    libelle
  end

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id)
  end

  def bienvenue?
    nom_technique == BIENVENUE
  end

  def numeratie?
    SITUATIONS_NUMERATIE.include?(nom_technique)
  end

  def litteratie?
    SITUATIONS_LITTERATIE.include?(nom_technique)
  end

  def positionnement?
    SITUATIONS_POSITIONNEMENT.include?(nom_technique)
  end

  def diagnostic?
    SITUATIONS_DIAGNOSTIC.include?(nom_technique)
  end

  def competences_transversales?
    SITUATIONS_COMPETENCES_TRANSVERSALES.include?(nom_technique)
  end

  private

  def nom_technique_ne_doit_pas_contenir_de_tirets
    if nom_technique.present? && nom_technique.include?("-")
      errors.add(:nom_technique, "ne doit pas contenir de tirets")
    end
  end
end
