class MiseEnAction < ApplicationRecord
  QUALIFICATION_INDETERMINEE = "indetermine".freeze
  REMEDIATIONS = %w[formation_competences_de_base formation_metier
                    dispositif_remobilisation levee_freins_peripheriques
                    indetermine autre].freeze
  DIFFICULTES = %w[aucune_offre_formation offre_formation_inaccessible
                   freins_peripheriques accompagnement_necessaire
                   indetermine autre].freeze
  QUALIFICATION_AUTRE = "autre".freeze
  LONGUEUR_MAX_PRECISION_AUTRE = 200
  MOTIFS = %w[action_prevue].freeze
  REPONSE_JE_NE_SAIS_PAS = "je_ne_sais_pas".freeze

  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true
  validate :qualification_coherente_avec_la_reponse
  validate :precision_presente_si_autre
  validates :precision_autre, length: { maximum: LONGUEUR_MAX_PRECISION_AUTRE }

  auto_strip_attributes :precision_autre

  before_validation :efface_precision_sans_autre

  enum :remediation, REMEDIATIONS.zip(REMEDIATIONS).to_h, suffix: true
  enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h, suffix: true
  enum :motif, MOTIFS.zip(MOTIFS).to_h, suffix: true

  acts_as_paranoid

  def self.je_ne_sais_pas_actif?
    # L'option "je ne sais pas" est activée si la variable d'environnement est définie
    # On peut supprimer cette vérification une fois l'ensemble de la feature livrée.
    # Sert de protection pour la prochaine mise en prod
    ENV["ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS"].present?
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
    return :motif if effectuee.nil?

    effectuee ? :remediation : :difficulte
  end

  def qualification
    send(questionnaire)
  end

  def qualifie(effectuee, qualification, precision_autre)
    self.effectuee = effectuee
    self[questionnaire] = qualification
    self.precision_autre = precision_autre
    save
  end

  def qualification_autre?
    qualification == QUALIFICATION_AUTRE
  end

  def qualification_indeterminee?
    qualification == QUALIFICATION_INDETERMINEE
  end

  def libelle_qualification
    return if qualification.blank? || qualification_indeterminee?

    I18n.t("activerecord.attributes.mise_en_action.#{questionnaire}.#{qualification}")
  end

  def libelle_repondue_le
    return if repondue_le.blank?

    I18n.t("reponse_mise_en_action.repondue_le",
           date: I18n.l(repondue_le.to_date, format: :short))
  end

  private

  # Une remédiation n'a de sens que sur une réponse Oui, une difficulté que sur une réponse Non
  def qualification_coherente_avec_la_reponse
    errors.add(:base, :remediation_incoherente) if remediation.present? && effectuee != true
    errors.add(:base, :difficulte_incoherente) if difficulte.present? && effectuee != false
  end

  def precision_presente_si_autre
    return unless qualification_autre? && precision_autre.blank?

    errors.add(:precision_autre, :"blank_#{questionnaire}")
  end

  def efface_precision_sans_autre
    return if qualification_autre?

    self.precision_autre = nil
  end
end
