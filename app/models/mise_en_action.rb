# frozen_string_literal: true

class MiseEnAction < ApplicationRecord
  DISPOSITIFS_REMEDIATION = %w[formation_competences_de_base formation_metier
                               dispositif_remobilisation levee_freins_peripheriques
                               indetermine].freeze
  DIFFICULTES = %w[aucune_offre_formation offre_formation_inaccessible
                   freins_peripheriques accompagnement_necessaire].freeze

  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true
  validates :effectuee, absence: false, inclusion: { in: [true, false] }

  before_save :enregistre_date

  enum :dispositif_de_remediation, DISPOSITIFS_REMEDIATION.zip(DISPOSITIFS_REMEDIATION).to_h
  enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h

  acts_as_paranoid

  def enregistre_date
    return unless repondue_le.nil?

    self.repondue_le = Time.zone.now
  end

  def effectuee_sans_dispositif_remediation?
    effectuee && dispositif_de_remediation.blank?
  end

  def effectuee?
    effectuee
  end
end
