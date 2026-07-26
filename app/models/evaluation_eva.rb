class EvaluationEva < Evaluation
  SYNTHESES = %w[illettrisme_potentiel socle_clea ni_ni aberrant].freeze
  NIVEAUX_CEFR = %w[pre_A1 A1 A2 B1].freeze
  NIVEAUX_CNEF = %w[pre_X1 X1 X2 Y1].freeze
  NIVEAUX_ANLCI = %w[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus].freeze
  NIVEAUX_POSITIONNEMENT = %w[profil1 profil2 profil3 profil4
                              profil_4h profil_4h_plus profil_4h_plus_plus
                              profil_aberrant indetermine].freeze
  NIVEAUX_NUMERATIE = %w[profil1 profil2 profil3 profil4 profil4_plus indetermine].freeze

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

  enum :synthese_competences_de_base, SYNTHESES.zip(SYNTHESES).to_h
  enum :niveau_cefr, NIVEAUX_CEFR.zip(NIVEAUX_CEFR).to_h, prefix: true
  enum :niveau_cnef, NIVEAUX_CNEF.zip(NIVEAUX_CNEF).to_h, prefix: true
  enum :niveau_anlci_litteratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :niveau_anlci_numeratie, NIVEAUX_ANLCI.zip(NIVEAUX_ANLCI).to_h, prefix: true
  enum :positionnement_niveau_litteratie,
       NIVEAUX_POSITIONNEMENT.zip(NIVEAUX_POSITIONNEMENT).to_h, prefix: true
  enum :positionnement_niveau_numeratie,
       NIVEAUX_NUMERATIE.zip(NIVEAUX_NUMERATIE).to_h, prefix: true

  scope :sans_mise_en_action, -> { where.missing(:mise_en_action) }
  scope :competences_de_base_completes, lambda {
    where(completude: %w[complete competences_transversales_incompletes])
  }

  def illettrisme_potentiel?
    synthese_competences_de_base == "illettrisme_potentiel" ||
      positionnement_niveau_numeratie_profil1? || positionnement_niveau_numeratie_profil2?
  end
end
