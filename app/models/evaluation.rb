# frozen_string_literal: true

class Evaluation < ApplicationRecord
  # Nb max d'évaluations que l'on peut télécharger dans le fichier XLS fixé de manière arbitraire
  # en fonction de ce que l'on est capable d'exporter en un temps raisonnable.
  LIMITE_EXPORT_XLS = 3000
  SYNTHESES = %w[illettrisme_potentiel socle_clea ni_ni aberrant].freeze
  NIVEAUX_CEFR = %w[pre_A1 A1 A2 B1].freeze
  NIVEAUX_CNEF = %w[pre_X1 X1 X2 Y1].freeze
  NIVEAUX_ANLCI = %w[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus].freeze
  NIVEAUX_POSITIONNEMENT = %w[profil1 profil2 profil3 profil4
                              profil_4h profil_4h_plus profil_4h_plus_plus
                              profil_aberrant indetermine].freeze
  NIVEAUX_NUMERATIE = %w[profil1 profil2 profil3 profil4 profil4_plus indetermine].freeze
  NIVEAUX_COMPLETUDE = %w[incomplete competences_de_base_incompletes
                          competences_transversales_incompletes complete].freeze
  SITUATION_COMPETENCES_TRANSVERSALES = %w[tri inventaire securite controle].freeze
  SITUATION_COMPETENCES_BASE = %w[maintenance livraison objets_trouves].freeze

  ACTIONS = {
    LIRE: { label: I18n.t("admin.evaluations.index.voir"),
            type: :read,
            url: :admin_evaluation_path },
    EDITER: { label: I18n.t("admin.evaluations.index.modifier"),
              type: :edit,
              url: :edit_admin_evaluation_path
    },
    SUPPRIMER: { label: I18n.t("admin.evaluations.index.supprimer"),
                 type: :destroy,
                 url: :admin_evaluation_path,
                 method: :delete,
                 data: { confirm: I18n.t("admin.evaluations.index.confirmation_suppression") }
    }
  }.freeze

  belongs_to :campagne
  belongs_to :beneficiaire
  belongs_to :responsable_suivi, optional: true, class_name: "Compte"

  has_one :conditions_passation, dependent: :destroy
  has_one :donnee_sociodemographique, dependent: :destroy
  has_one :mise_en_action, dependent: :destroy
  has_many :parties, dependent: :destroy

  before_validation :trouve_campagne_depuis_code
  validates :debutee_le, :statut, presence: true
  validate :code_campagne_connu

  accepts_nested_attributes_for :conditions_passation
  accepts_nested_attributes_for :donnee_sociodemographique
  accepts_nested_attributes_for :mise_en_action
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
  enum :positionnement_niveau_numeratie,
       NIVEAUX_NUMERATIE.zip(NIVEAUX_NUMERATIE).to_h, prefix: true
  enum :completude, NIVEAUX_COMPLETUDE.zip(NIVEAUX_COMPLETUDE).to_h
  enum :statut, { a_suivre: 0, suivi_en_cours: 1, suivi_effectue: 2 }

  scope :des_12_derniers_mois, lambda {
    dernier_mois_complete = 1.month.ago.end_of_month
    il_y_a_12_mois = (dernier_mois_complete - 11.months).beginning_of_month
    where(created_at: il_y_a_12_mois..dernier_mois_complete)
  }
  scope :pour_les_structures, lambda { |structures|
    joins(campagne: { compte: :structure })
      .where(campagnes: { comptes: { structure_id: structures } })
  }
  scope :non_anonymes, -> { where(anonymise_le: nil) }
  scope :sans_mise_en_action, -> { where.missing(:mise_en_action) }
  scope :competences_de_base_completes, lambda {
    where(completude: %w[complete competences_transversales_incompletes])
  }
  scope :pour_beneficiaires, ->(ids) { where(beneficiaire_id: ids) }
  scope :avec_type_de_programme, ->(type) {
    joins(campagne: :parcours_type)
    .where(parcours_type: { type_de_programme: type })
  }
  scope :diagnostic, -> { avec_type_de_programme(:diagnostic) }
  scope :positionnement, -> { avec_type_de_programme(:positionnement) }

  def self.reponses_redaction_pour_evaluations(evaluation_ids)
    question_redaction_id = find_question_redaction_id
    return {} if question_redaction_id.nil? || evaluation_ids.empty?

    reponses_redaction = executer_requete_reponses_redaction(evaluation_ids, question_redaction_id)
    grouper_reponses_par_evaluation(reponses_redaction)
  end

  private_class_method def self.find_question_redaction_id
    Question.find_by(nom_technique: QuestionSaisie::QUESTION_REDACTION)&.id
  end

  private_class_method def self.executer_requete_reponses_redaction(evaluation_ids,
question_redaction_id)
    evaluation_ids_sql = evaluation_ids.map { |id| connection.quote(id) }.join(",")
    sql_params = [ Restitution::MetriquesHelper::EVENEMENT[:REPONSE], question_redaction_id ]

    connection.select_all(
      sanitize_sql_array([ sql_reponses_redaction(evaluation_ids_sql) ] + sql_params))
  end

  private_class_method def self.sql_reponses_redaction(evaluation_ids_sql)
    <<~SQL.squish
      SELECT
        p.evaluation_id,
        e.donnees ->> 'reponse' as reponse,
        e.created_at
      FROM (
        SELECT parties.session_id, parties.evaluation_id
        FROM parties
        WHERE parties.deleted_at IS NULL
          AND parties.evaluation_id IN (#{evaluation_ids_sql})
      ) as p
      INNER JOIN evenements e ON e.session_id = p.session_id AND e.deleted_at IS NULL
      WHERE e.nom = ?
        AND e.donnees ->> 'question' = ?
        AND e.donnees ->> 'reponse' IS NOT NULL
        AND e.donnees ->> 'reponse' != ''
      ORDER BY p.evaluation_id, e.created_at
    SQL
  end

  private_class_method def self.grouper_reponses_par_evaluation(reponses_redaction)
    reponses_redaction
      .group_by { |row| row["evaluation_id"] }
      .transform_values { |reponses| reponses.map { |r| r["reponse"] } }
  end

  def display_name
    "#{beneficiaire.nom} - #{I18n.l(debutee_le, format: :avec_heure)}"
  end

  def anonyme?
    anonymise_le.present?
  end

  def responsables_suivi
    Compte.where(structure_id: campagne&.compte&.structure_id).where(statut_validation: :acceptee)
  end

  def beneficiaires_possibles
    Beneficiaire.joins(evaluations: { campagne: :compte }).where(evaluations: { campagnes:
    { comptes: { structure_id: campagne&.compte&.structure_id } } })
  end

  def self.tableau_de_bord(ability)
    accessible_by(ability).non_anonymes.order(created_at: :desc)
  end

  def self.tableau_de_bord_mises_en_action(ability)
    accessible_by(ability).illettrisme_potentiel
                          .sans_mise_en_action
                          .competences_de_base_completes
                          .non_anonymes
                          .order(created_at: :desc)
                          .includes(:mise_en_action)
  end

  def enregistre_mise_en_action(reponse)
    mise_en_action = MiseEnAction.find_or_initialize_by(evaluation: self)
    mise_en_action.effectuee = reponse
    mise_en_action.save
  end

  def a_mise_en_action?
    @a_mise_en_action ||= mise_en_action.present?
  end

  def illettrisme_potentiel?
    synthese_competences_de_base == "illettrisme_potentiel" ||
      positionnement_niveau_numeratie_profil1? || positionnement_niveau_numeratie_profil2?
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
