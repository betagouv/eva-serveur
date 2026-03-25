# frozen_string_literal: true

module Evaluations
  class PassationBeneficiaire
    attr_reader :evaluation

    def initialize(evaluation)
      @evaluation = evaluation
    end

    def evapro?
      false
    end

    def enregistre_mise_en_action(effectuee)
      @evaluation.enregistre_mise_en_action(effectuee)
    end

    def a_mise_en_action?
      @evaluation.a_mise_en_action?
    end

    def mise_en_action_presenter
      MiseEnActionPresenter.new(evaluation)
    end

    class MiseEnActionPresenter
      def initialize(evaluation)
        @evaluation = evaluation
      end

      def a_mise_en_action?
        @evaluation.a_mise_en_action?
      end

      def effectuee_avec_remediation?
        @evaluation&.mise_en_action&.effectuee_avec_remediation?
      end

      def effectuee_sans_remediation?
        @evaluation&.mise_en_action&.effectuee &&
          @evaluation&.mise_en_action&.remediation.blank?
      end

      def non_effectuee_sans_difficulte?
        @evaluation&.mise_en_action&.effectuee == false &&
          @evaluation&.mise_en_action&.difficulte.blank?
      end

      def non_effectuee_avec_difficulte?
        @evaluation&.mise_en_action&.non_effectuee_avec_difficulte?
      end

      def mise_en_action_avec_qualification?
        effectuee_avec_remediation? || non_effectuee_avec_difficulte?
      end
    end
  end
end
