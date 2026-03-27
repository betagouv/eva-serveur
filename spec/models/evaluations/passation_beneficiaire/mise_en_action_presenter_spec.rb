# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire::MiseEnActionPresenter do
  describe "#mise_en_action_avec_qualification?" do
    it "retourne true quand la mise en action est effectuée avec remédiation" do
      mise_en_action = instance_double(MiseEnAction, effectuee_avec_remediation?: true)
      evaluation = instance_double(Evaluation, mise_en_action: mise_en_action)

      presenter = described_class.new(evaluation)

      expect(presenter.effectuee_avec_remediation?).to be(true)
      expect(presenter.mise_en_action_avec_qualification?).to be(true)
    end

    it "retourne true quand la mise en action est non effectuée avec difficulté" do
      mise_en_action = instance_double(MiseEnAction,
                                       effectuee_avec_remediation?: false,
                                       non_effectuee_avec_difficulte?: true)
      evaluation = instance_double(Evaluation, mise_en_action: mise_en_action)

      presenter = described_class.new(evaluation)

      expect(presenter.non_effectuee_avec_difficulte?).to be(true)
      expect(presenter.mise_en_action_avec_qualification?).to be(true)
    end
  end
end
