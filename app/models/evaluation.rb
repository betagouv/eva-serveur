# frozen_string_literal: true

class Evaluation < ApplicationRecord
  SYNTHESES = %w[illettrisme_potentiel socle_clea ni_ni].freeze
  NIVEAUX_CEFR = %w[pre_A1 A1 A2 B1].freeze
  NIVEAUX_CNEF = %w[pre_X1 X1 X2 Y1].freeze
  NIVEAUX_ANLCI = %w[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus].freeze
  NIVEAUX_COMPLETUDE = %w[incomplete
                          competences_de_base_incompletes
                          competences_transversalles_incompletes
                          complete].freeze

  validates :nom, :debutee_le, presence: true
  belongs_to :campagne, counter_cache: :nombre_evaluations
  attr_accessor :code_campagne

  before_validation :trouve_campagne_depuis_code
  validate :code_campagne_connu

  enum :synthese_competences_de_base, SYNTHESES.zip(SYNTHESES).to_h
  enum :niveau_cefr, NIVEAUX_CEFR.zip(NIVEAUX_CEFR).to_h, prefix: true
  enum :niveau_cnef, NIVEAUX_CNEF.zip(NIVEAUX_CNEF).to_h, prefix: true
  enum :niveau_anlci_litteratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :niveau_anlci_numeratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :completude, NIVEAUX_COMPLETUDE.zip(NIVEAUX_COMPLETUDE).to_h

  scope :des_3_derniers_mois, lambda {
    il_y_a_3_mois = (Date.current - 2.months).beginning_of_month
    where('evaluations.created_at > ?', il_y_a_3_mois)
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

  def display_name
    nom
  end

  def anonyme?
    anonymise_le.present?
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
