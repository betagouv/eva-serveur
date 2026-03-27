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
      mise_en_action = MiseEnAction.find_or_initialize_by(evaluation: @evaluation)
      mise_en_action.effectuee = effectuee
      mise_en_action.repondue_le = Time.zone.now

      if effectuee
        mise_en_action.difficulte = nil
      else
        mise_en_action.remediation = nil
      end
      mise_en_action.save
    end

    def a_mise_en_action?
      @a_mise_en_action ||= @evaluation.mise_en_action.present?
    end

    def mise_en_action_presenter
      MiseEnActionPresenter.new(evaluation)
    end
  end
end
