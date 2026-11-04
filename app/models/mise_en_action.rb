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
  DELAIS_REVUE = { "7_jours" => 7.days, "14_jours" => 14.days, "1_mois" => 1.month }.freeze
  CHOIX_DATE_PRECISE = "date_precise".freeze
  CHOIX_DATE_REVUE = [ *DELAIS_REVUE.keys, CHOIX_DATE_PRECISE ].freeze

  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true
  validate :qualification_coherente_avec_la_reponse
  validate :precision_presente_si_autre
  # Au jour du choix, pas à repondue_le (voir ADR 0003)
  validate :date_revue_a_partir_de_demain, if: :date_revue_changed?
  validates :precision_autre, length: { maximum: LONGUEUR_MAX_PRECISION_AUTRE }

  auto_strip_attributes :precision_autre

  before_validation :efface_precision_sans_autre

  enum :remediation, REMEDIATIONS.zip(REMEDIATIONS).to_h, suffix: true
  enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h, suffix: true
  enum :motif, MOTIFS.zip(MOTIFS).to_h, suffix: true
  enum :choix_date_revue, CHOIX_DATE_REVUE.zip(CHOIX_DATE_REVUE).to_h, prefix: true

  acts_as_paranoid

  scope :repondues_pas_encore, -> { where(effectuee: nil).where.not(repondue_le: nil) }
  scope :reportees, -> { repondues_pas_encore.where("date_revue > ?", Date.current) }

  def self.je_ne_sais_pas_actif?
    # L'option "je ne sais pas" est activée si la variable d'environnement est définie
    # On peut supprimer cette vérification une fois l'ensemble de la feature livrée.
    # Sert de protection pour la prochaine mise en prod
    ENV["ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS"].present?
  end

  def repondu_oui?
    effectuee == true
  end

  def repondu_non?
    effectuee == false
  end

  def repondu_pas_encore?
    repondue_le.present? && effectuee.nil?
  end

  def date_revue_a_choisir?
    repondu_pas_encore? && date_revue.blank?
  end

  # Même règle que le scope reportees, sur une seule mise en action
  def reportee?
    repondu_pas_encore? && date_revue.present? && date_revue > Date.current
  end

  # Une qualification ignorée ("Ignorer" du tableau de bord) reste à renseigner
  def qualification_a_renseigner?
    qualification.blank? || qualification_indeterminee?
  end

  def effectuee_avec_remediation?
    repondu_oui? && !qualification_a_renseigner?
  end

  def effectuee_sans_remediation?
    repondu_oui? && qualification_a_renseigner?
  end

  def non_effectuee_avec_difficulte?
    repondu_non? && !qualification_a_renseigner?
  end

  def non_effectuee_sans_difficulte?
    repondu_non? && qualification_a_renseigner?
  end

  def questionnaire
    return :motif if repondu_pas_encore?

    repondu_oui? ? :remediation : :difficulte
  end

  def qualification
    send(questionnaire)
  end

  def enregistre_reponse(effectuee)
    self.effectuee = effectuee
    self.repondue_le = Time.zone.now
    efface_qualification_ancienne_reponse
    save
  end

  # La date de revue se déduit du choix ; seule une date précise est transmise
  def reporte_dans(choix_date_revue, date_precise = nil)
    return false unless CHOIX_DATE_REVUE.include?(choix_date_revue)

    self.choix_date_revue = choix_date_revue
    self.date_revue = date_revue_selon(choix_date_revue, date_precise)
    save
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
    if qualification_autre?
      return I18n.t("reponse_mise_en_action.autre", precision: precision_autre)
    end

    I18n.t("activerecord.attributes.mise_en_action.#{questionnaire}.#{qualification}")
  end

  def libelle_repondue_le
    return if repondue_le.blank?

    I18n.t("reponse_mise_en_action.repondue_le",
           date: I18n.l(repondue_le.to_date, format: :short))
  end

  private

  def date_revue_selon(choix_date_revue, date_precise)
    return date_precise if choix_date_revue == CHOIX_DATE_PRECISE

    Date.current + DELAIS_REVUE[choix_date_revue]
  end

  def efface_qualification_ancienne_reponse
    self.remediation = nil unless repondu_oui?
    self.difficulte = nil unless repondu_non?
    if repondu_pas_encore?
      assign_attributes(motif: :action_prevue, date_revue: Date.current + 7)
    else
      assign_attributes(motif: nil, date_revue: nil, choix_date_revue: nil)
    end
  end

  # Une remédiation n'a de sens que sur une réponse Oui, une difficulté que sur une réponse Non
  def qualification_coherente_avec_la_reponse
    errors.add(:base, :remediation_incoherente) if remediation.present? && !repondu_oui?
    errors.add(:base, :difficulte_incoherente) if difficulte.present? && !repondu_non?
  end

  def date_revue_a_partir_de_demain
    return if date_revue.blank? || date_revue > Date.current

    errors.add(:date_revue, :a_partir_de_demain)
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
