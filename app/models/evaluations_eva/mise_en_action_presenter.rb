module EvaluationsEva
  class MiseEnActionPresenter
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def a_mise_en_action?
      @evaluation.mise_en_action.present?
    end

    def effectuee_avec_remediation?
      reponse?(true) && !qualification_a_renseigner?
    end

    def effectuee_sans_remediation?
      reponse?(true) && qualification_a_renseigner?
    end

    def non_effectuee_sans_difficulte?
      reponse?(false) && qualification_a_renseigner?
    end

    def non_effectuee_avec_difficulte?
      reponse?(false) && !qualification_a_renseigner?
    end

    def mise_en_action_avec_qualification?
      effectuee_avec_remediation? || non_effectuee_avec_difficulte?
    end

    def je_ne_sais_pas_affiche?
      MiseEnAction.je_ne_sais_pas_actif? && a_mise_en_action? &&
        @evaluation.mise_en_action.effectuee.nil?
    end

    def reponse_affichee?
      mise_en_action_avec_qualification? || je_ne_sais_pas_affiche?
    end

    private

    def mise_en_action
      @evaluation&.mise_en_action
    end

    def reponse?(effectuee)
      mise_en_action.present? && mise_en_action.effectuee == effectuee
    end

    # Une qualification ignorée ("Ignorer" du tableau de bord) reste à renseigner
    def qualification_a_renseigner?
      mise_en_action.qualification.blank? || mise_en_action.qualification_indeterminee?
    end
  end
end
