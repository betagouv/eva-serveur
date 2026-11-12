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
  REPONSE_PAS_ENCORE = "pas_encore".freeze
  DELAIS_REVUE = { "7_jours" => 7.days, "14_jours" => 14.days, "1_mois" => 1.month }.freeze
  CHOIX_DATE_PRECISE = "date_precise".freeze
  CHOIX_DATE_REVUE = [ *DELAIS_REVUE.keys, CHOIX_DATE_PRECISE ].freeze

  # L'évaluation depuis laquelle la réponse a été donnée ; la mise en action, elle, vaut
  # pour le bénéficiaire dans sa structure (EVA-1186)
  belongs_to :evaluation
  belongs_to :beneficiaire
  belongs_to :structure
  belongs_to :repondue_par, class_name: "Compte", optional: true

  validates :beneficiaire_id,
            uniqueness: { scope: :structure_id, conditions: -> { en_cours } },
            if: :en_cours?
  validate :qualification_coherente_avec_la_reponse
  validate :precision_presente_si_autre
  validate :date_revue_presente_si_date_precise
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

  scope :en_cours, -> { where(remplacee_le: nil) }
  scope :repondues_pas_encore, -> { where(effectuee: nil).where.not(repondue_le: nil) }
  scope :reportees, -> { repondues_pas_encore.where("date_revue > ?", Date.current) }

  # La déclaration qui vaut aujourd'hui pour cette personne dans cette structure
  def self.en_cours_pour(beneficiaire_id, structure_id)
    MisesEnAction::EnCours.pour(beneficiaire_id, structure_id)
  end

  def self.pas_encore_actif?
    # L'option "Pas encore" est activée si la variable d'environnement est définie
    # On peut supprimer cette vérification une fois l'ensemble de la feature livrée.
    # Sert de protection pour la prochaine mise en prod
    ENV["ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS"].present?
  end

  def en_cours?
    remplacee_le.nil?
  end

  # Conservée pour les statistiques de l'ANLCI et un futur historique, mais plus affichée
  def remplace!
    update_column(:remplacee_le, Time.zone.now)
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

  def date_de_revue_atteinte?
    repondu_pas_encore? && date_revue.present? && date_revue <= Date.current
  end

  # Une qualification ignorée (ancien "Ignorer" du tableau de bord) reste à renseigner :
  # plus aucun écran ne l'enregistre, les valeurs existantes restent à compléter
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

  def libelle_relance_prevue
    return if date_revue.blank?

    I18n.t("reponse_mise_en_action.relance_prevue", date: I18n.l(date_revue, format: :short))
  end

  # La réponse peut avoir été donnée depuis une autre évaluation de la personne : l'évaluation
  # d'origine est alors rappelée (EVA-1186)
  def libelle_repondue_le(evaluation_affichee = nil)
    return if repondue_le.blank?

    I18n.t("reponse_mise_en_action.repondue_le",
           date: I18n.l(repondue_le.to_date, format: :short),
           auteur: libelle_auteur,
           origine: libelle_evaluation_origine(evaluation_affichee))
  end

  private

  def libelle_auteur
    return "" if repondue_par.blank?

    I18n.t("reponse_mise_en_action.auteur", compte: repondue_par.nom_abrege)
  end

  def libelle_evaluation_origine(evaluation_affichee)
    return "" if evaluation_affichee.blank? || evaluation_affichee.id == evaluation_id
    return "" if evaluation&.debutee_le.blank?

    I18n.t("reponse_mise_en_action.origine",
           date: I18n.l(evaluation.debutee_le.to_date, format: :short))
  end

  def date_revue_selon(choix_date_revue, date_precise)
    return date_precise if choix_date_revue == CHOIX_DATE_PRECISE

    Date.current + DELAIS_REVUE[choix_date_revue]
  end

  def efface_qualification_ancienne_reponse
    self.remediation = nil unless repondu_oui?
    self.difficulte = nil unless repondu_non?
    assign_attributes(motif: nil, date_revue: nil, choix_date_revue: nil) unless repondu_pas_encore?
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

  def date_revue_presente_si_date_precise
    return unless choix_date_revue == CHOIX_DATE_PRECISE && date_revue.blank?

    errors.add(:date_revue, :blank)
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
