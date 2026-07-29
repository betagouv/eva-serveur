class Evaluation < ApplicationRecord
  NIVEAUX_COMPLETUDE = %w[incomplete competences_de_base_incompletes
                          competences_transversales_incompletes complete].freeze
  SITUATION_COMPETENCES_TRANSVERSALES = %w[tri inventaire securite controle].freeze
  SITUATION_COMPETENCES_BASE = %w[maintenance livraison objets_trouves].freeze

  belongs_to :campagne
  belongs_to :beneficiaire

  delegate :structure, to: :campagne

  has_one :conditions_passation, dependent: :destroy
  has_many :parties, dependent: :destroy

  before_validation :trouve_campagne_depuis_code
  validates :debutee_le, :statut, presence: true
  validate :code_campagne_connu

  accepts_nested_attributes_for :conditions_passation
  accepts_nested_attributes_for :beneficiaire, update_only: true
  attr_accessor :code_campagne

  acts_as_paranoid

  enum :completude, NIVEAUX_COMPLETUDE.zip(NIVEAUX_COMPLETUDE).to_h

  scope :pour_les_structures, lambda { |structures|
    joins(campagne: { compte: :structure })
      .where(campagnes: { comptes: { structure_id: structures } })
  }
  scope :non_anonymes, -> { joins(:beneficiaire).where(beneficiaires: { anonymise_le: nil }) }
  scope :pour_beneficiaires, ->(ids) { where(beneficiaire_id: ids) }
  scope :avec_type_de_programme, ->(type) {
    joins(campagne: :parcours_type)
    .where(parcours_type: { type_de_programme: type })
  }
  scope :pour_structure, lambda { |structure|
    return none if structure.blank?

    joins(campagne: :compte).where(comptes: { structure_id: structure.id })
  }
  scope :avec_reponse, lambda {
    joins(parties: :evenements)
      .merge(Evenement.reponses)
      .where(
        "(evenements.donnees ->> 'reponse' IS NOT NULL" \
        " AND evenements.donnees ->> 'reponse' != '')" \
        " OR (evenements.donnees ->> 'reponseIntitule' IS NOT NULL" \
        " AND evenements.donnees ->> 'reponseIntitule' != '')"
      )
      .distinct
  }

  delegate :anonyme?, to: :beneficiaire

  def self.reponses_redaction_pour_evaluations(evaluation_ids)
    question_redaction_id = find_question_redaction_id
    return {} if question_redaction_id.nil? || evaluation_ids.empty?

    reponses_redaction = executer_requete_reponses_redaction(evaluation_ids, question_redaction_id)
    grouper_reponses_par_evaluation(reponses_redaction)
  end

  def self.au_moins_une_reponse_pour_structure?(structure)
    pour_structure(structure).avec_reponse.exists?
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

  def beneficiaires_possibles
    Beneficiaire.joins(evaluations: { campagne: :compte }).where(evaluations: { campagnes:
    { comptes: { structure_id: campagne&.compte&.structure_id } } })
  end

  def context
    @context ||= Context.new(self)
  end

  def evapro?
    context.pro?
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
