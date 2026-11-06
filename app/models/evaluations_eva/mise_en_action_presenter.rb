module EvaluationsEva
  class MiseEnActionPresenter
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def a_mise_en_action?
      @evaluation.mise_en_action.present?
    end

    def effectuee_avec_remediation?
      mise_en_action.present? && mise_en_action.effectuee_avec_remediation?
    end

    def effectuee_sans_remediation?
      mise_en_action.present? && mise_en_action.effectuee_sans_remediation?
    end

    def non_effectuee_sans_difficulte?
      mise_en_action.present? && mise_en_action.non_effectuee_sans_difficulte?
    end

    def non_effectuee_avec_difficulte?
      mise_en_action.present? && mise_en_action.non_effectuee_avec_difficulte?
    end

    def mise_en_action_avec_qualification?
      effectuee_avec_remediation? || non_effectuee_avec_difficulte?
    end

    def date_revue_a_choisir?
      pas_encore_disponible? && mise_en_action.date_revue_a_choisir?
    end

    def pas_encore_affiche?
      pas_encore_disponible? && mise_en_action.reportee?
    end

    def rappel_pas_encore?
      pas_encore_disponible? && mise_en_action.date_de_revue_atteinte?
    end

    def reponse_affichee?
      mise_en_action_avec_qualification? || pas_encore_affiche?
    end

    private

    def mise_en_action
      @evaluation&.mise_en_action
    end

    def pas_encore_disponible?
      MiseEnAction.pas_encore_actif? && mise_en_action.present?
    end
  end
end
