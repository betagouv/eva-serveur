# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire do
  describe "#evapro?" do
    it "retourne false" do
      expect(described_class.new(double).evapro?).to be(false)
    end
  end

  describe "#a_mise_en_action?" do
    it "délègue à l'évaluation" do
      evaluation = instance_double(Evaluation, a_mise_en_action?: true)

      expect(described_class.new(evaluation).a_mise_en_action?).to be(true)
    end
  end
end
