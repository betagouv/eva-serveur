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
  end
end
