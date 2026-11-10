class EvaluationEva < Evaluation
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

  ACTIONS = {
    LIRE: { label: I18n.t("admin.evaluations_eva.index.voir"),
            type: :read,
            url: :admin_evaluation_eva_path },
    EDITER: { label: I18n.t("admin.evaluations_eva.index.modifier"),
              type: :edit,
              url: :edit_admin_evaluation_eva_path
    },
    SUPPRIMER: { label: I18n.t("admin.evaluations_eva.index.supprimer"),
                 type: :destroy,
                 url: :admin_evaluation_eva_path,
                 method: :delete,
                 data: { confirm: I18n.t("admin.evaluations_eva.index.confirmation_suppression") }
    }
  }.freeze

  belongs_to :responsable_suivi, optional: true, class_name: "Compte"

  # La mise en action déclarée depuis cette évaluation ; celle qui s'applique à l'évaluation
  # est cherchée par bénéficiaire et structure (voir #mise_en_action)
  has_one :mise_en_action_declaree, class_name: "MiseEnAction",
          foreign_key: :evaluation_id, dependent: :destroy, inverse_of: :evaluation
  has_one :donnee_sociodemographique, foreign_key: :evaluation_id, dependent: :destroy

  enum :statut, { a_suivre: 0, suivi_en_cours: 1, suivi_effectue: 2 }
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

  scope :mise_en_action_a_renseigner, lambda {
    where("#{EvaluationsEva::StatutSuivi.sql_reponse_mise_en_action} IS NULL")
      .where("NOT (#{EvaluationsEva::StatutSuivi.sql_mise_en_action_reportee})")
  }
  scope :competences_de_base_completes, lambda {
    where(completude: %w[complete competences_transversales_incompletes])
  }
  scope :statut_suivi_in, lambda { |*statuts|
    EvaluationsEva::StatutSuivi.filtre_par_statuts(all, statuts.flatten)
  }
  scope :diagnostic, -> { avec_type_de_programme(:diagnostic) }
  scope :positionnement, -> { avec_type_de_programme(:positionnement) }

  def self.ransackable_scopes(_auth_object = nil)
    %i[statut_suivi_in]
  end

  def classe_restitution
    Restitution::GlobaleEva
  end

  def illettrisme_potentiel?
    synthese_competences_de_base == "illettrisme_potentiel" ||
      positionnement_niveau_numeratie_profil1? || positionnement_niveau_numeratie_profil2?
  end

  def responsables_suivi
    Compte.where(structure_id: campagne&.compte&.structure_id).where(statut_validation: :acceptee)
  end

  # La déclaration qui s'applique : une seule par personne et par structure, quelle que soit
  # l'évaluation depuis laquelle elle a été donnée (EVA-1186)
  def mise_en_action
    return @mise_en_action if defined?(@mise_en_action)

    @mise_en_action = MiseEnAction.en_cours_pour(beneficiaire_id, structure&.id)
  end

  attr_writer :mise_en_action

  def reload(...)
    remove_instance_variable(:@mise_en_action) if defined?(@mise_en_action)
    super
  end

  # "Modifier la réponse" remplace la déclaration en cours par une nouvelle
  def enregistre_mise_en_action(effectuee, compte: nil, modification: false)
    courante = mise_en_action
    courante.remplace! if modification && courante.present?
    self.mise_en_action = nouvelle_mise_en_action(modification ? nil : courante, compte)
    mise_en_action.enregistre_reponse(effectuee)
  end

  def mise_en_action_presenter
    EvaluationsEva::MiseEnActionPresenter.new(self)
  end

  private

  # Répondre depuis cette évaluation en fait l'évaluation d'origine de la déclaration
  def nouvelle_mise_en_action(courante, compte)
    mise_en_action = courante || MiseEnAction.new(beneficiaire_id: beneficiaire_id,
                                                  structure_id: structure&.id)
    mise_en_action.evaluation = self
    mise_en_action.repondue_par = compte if compte.present?
    mise_en_action
  end
end
