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
      MiseEnAction.je_ne_sais_pas_actif? && mise_en_action.present? &&
        mise_en_action.date_revue_a_choisir?
    end

    def je_ne_sais_pas_affiche?
      MiseEnAction.je_ne_sais_pas_actif? && a_mise_en_action? &&
        @evaluation.mise_en_action.repondu_pas_encore?
    end

    def reponse_affichee?
      mise_en_action_avec_qualification? || je_ne_sais_pas_affiche?
    end

    private

    def mise_en_action
      @evaluation&.mise_en_action
    end
  end
end
