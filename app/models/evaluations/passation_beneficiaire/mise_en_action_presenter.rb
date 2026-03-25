# frozen_string_literal: true

module Evaluations
  class PassationBeneficiaire
    class MiseEnActionPresenter
      def initialize(evaluation)
        @evaluation = evaluation
      end

      def a_mise_en_action?
        @evaluation.mise_en_action.present?
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
