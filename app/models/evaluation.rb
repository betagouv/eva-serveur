# frozen_string_literal: true

class Evaluation < ApplicationRecord
  SYNTHESES = %w[illettrisme_potentiel socle_clea ni_ni aberrant].freeze
  NIVEAUX_CEFR = %w[pre_A1 A1 A2 B1].freeze
  NIVEAUX_CNEF = %w[pre_X1 X1 X2 Y1].freeze
  NIVEAUX_ANLCI = %w[profil1 profil2 profil3
                     profil4 profil4_plus profil4_plus_plus].freeze
  NIVEAUX_POSITIONNEMENT = %w[profil1 profil2 profil3 profil4
                              profil_4h profil_4h_plus profil_4h_plus_plus
                              profil_aberrant indetermine].freeze
  NIVEAUX_COMPLETUDE = %w[incomplete
                          competences_de_base_incompletes
                          competences_transversales_incompletes
                          complete].freeze
  SITUATION_COMPETENCES_TRANSVERSALES = %w[tri inventaire securite controle].freeze
  SITUATION_COMPETENCES_BASE = %w[maintenance livraison objets_trouves].freeze

  belongs_to :campagne, counter_cache: :nombre_evaluations
  belongs_to :beneficiaire
  belongs_to :responsable_suivi, optional: true, class_name: 'Compte'

  has_one :conditions_passation, dependent: :destroy
  has_one :donnee_sociodemographique, dependent: :destroy
  has_many :parties, dependent: :destroy

  before_validation :trouve_campagne_depuis_code
  after_update :enregistre_date, if: :saved_change_to_mise_en_action_effectuee?
  validates :nom, :debutee_le, presence: true
  validate :code_campagne_connu

  accepts_nested_attributes_for :conditions_passation
  accepts_nested_attributes_for :donnee_sociodemographique
  accepts_nested_attributes_for :beneficiaire, update_only: true
  attr_accessor :code_campagne

  acts_as_paranoid

  enum :synthese_competences_de_base, SYNTHESES.zip(SYNTHESES).to_h
  enum :niveau_cefr, NIVEAUX_CEFR.zip(NIVEAUX_CEFR).to_h, prefix: true
  enum :niveau_cnef, NIVEAUX_CNEF.zip(NIVEAUX_CNEF).to_h, prefix: true
  enum :niveau_anlci_litteratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :niveau_anlci_numeratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :positionnement_niveau_litteratie,
       NIVEAUX_POSITIONNEMENT.zip(NIVEAUX_POSITIONNEMENT).to_h, prefix: true
  enum :completude, NIVEAUX_COMPLETUDE.zip(NIVEAUX_COMPLETUDE).to_h
  enum :statut, %i[a_suivre suivi_en_cours suivi_effectue]

  scope :des_12_derniers_mois, lambda {
    dernier_mois_complete = 1.month.ago.end_of_month
    il_y_a_12_mois = (dernier_mois_complete - 11.months).beginning_of_month
    where(created_at: il_y_a_12_mois..dernier_mois_complete)
  }
  scope :pour_les_structures, lambda { |structures|
    joins(campagne: { compte: :structure })
      .where(
        campagnes: {
          comptes: {
            structure_id: structures
          }
        }
      )
  }
  scope :non_anonymes, -> { where(anonymise_le: nil) }

  def display_name
    nom
  end

  def anonyme?
    anonymise_le.present?
  end

  def responsables_suivi
    Compte
      .where(structure_id: campagne&.compte&.structure_id)
      .where(statut_validation: :acceptee)
  end

  def enregistre_date
    update(mise_en_action_le: Time.zone.now)
  end

  def self.tableau_de_bord(ability)
    accessible_by(ability)
      .non_anonymes
      .order(created_at: :desc)
      .limit(10)
  end

  def self.illettrismes_sans_mise_en_action(ability)
    accessible_by(ability)
      .where(mise_en_action_effectuee: nil)
      .illettrisme_potentiel
      .non_anonymes
      .order(created_at: :desc)
      .limit(6)
  end

  private

  def trouve_campagne_depuis_code
    return if code_campagne.blank?

    self.campagne = Campagne.par_code(code_campagne).take
  end

  def code_campagne_connu
    return if code_campagne.blank? || campagne.present?

    errors.add(:code_campagne, :inconnu)
  end
end
