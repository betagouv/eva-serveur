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
end
