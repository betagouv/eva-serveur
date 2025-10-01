class MiseEnAction < ApplicationRecord
  REMEDIATIONS = %w[formation_competences_de_base formation_metier
                    dispositif_remobilisation levee_freins_peripheriques
                    indetermine].freeze
  DIFFICULTES = %w[aucune_offre_formation offre_formation_inaccessible
                   freins_peripheriques accompagnement_necessaire
                   indetermine].freeze

  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true
  validates :effectuee, absence: false, inclusion: { in: [ true, false ] }

  before_save :enregistre_date

  enum :remediation, REMEDIATIONS.zip(REMEDIATIONS).to_h, suffix: true
  enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h, suffix: true

  acts_as_paranoid

  def enregistre_date
    return unless repondue_le.nil?

    self.repondue_le = Time.zone.now
  end

  def effectuee_avec_remediation?
    effectuee && remediation.present?
  end

  def non_effectuee_avec_difficulte?
    effectuee == false && difficulte.present?
  end

  def effectuee?
    effectuee
  end

  def questionnaire
    effectuee ? :remediation : :difficulte
  end

  def qualification
    return if effectuee.nil?

    send(questionnaire)
  end
end
