class EvaluationEva < Evaluation
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

  SYNTHESES = %w[illettrisme_potentiel socle_clea ni_ni aberrant].freeze

  enum :synthese_competences_de_base, SYNTHESES.zip(SYNTHESES).to_h

  scope :sans_mise_en_action, -> { where.missing(:mise_en_action) }
  scope :competences_de_base_completes, lambda {
    where(completude: %w[complete competences_transversales_incompletes])
  }

  def illettrisme_potentiel?
    synthese_competences_de_base == "illettrisme_potentiel" ||
      positionnement_niveau_numeratie_profil1? || positionnement_niveau_numeratie_profil2?
  end
end
