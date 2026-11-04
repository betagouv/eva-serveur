module EvaluationsEva
  class MiseEnActionPresenter
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def a_mise_en_action?
      @evaluation.mise_en_action.present?
    end

    def effectuee_avec_remediation?
      repondu_oui? && !qualification_a_renseigner?
    end

    def effectuee_sans_remediation?
      repondu_oui? && qualification_a_renseigner?
    end

    def non_effectuee_sans_difficulte?
      repondu_non? && qualification_a_renseigner?
    end

    def non_effectuee_avec_difficulte?
      repondu_non? && !qualification_a_renseigner?
    end

    def mise_en_action_avec_qualification?
      effectuee_avec_remediation? || non_effectuee_avec_difficulte?
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

    def repondu_oui?
      mise_en_action.present? && mise_en_action.repondu_oui?
    end

    def repondu_non?
      mise_en_action.present? && mise_en_action.repondu_non?
    end

    # Une qualification ignorée ("Ignorer" du tableau de bord) reste à renseigner
    def qualification_a_renseigner?
      mise_en_action.qualification.blank? || mise_en_action.qualification_indeterminee?
    end
  end
end
