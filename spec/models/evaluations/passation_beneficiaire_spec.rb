# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire do
  describe "#evapro?" do
    it "retourne false" do
      expect(described_class.new(double).evapro?).to be(false)
    end
  end

  describe "#a_mise_en_action?" do
    it "retourne true lorsqu'une mise en action est associée à l'évaluation" do
      evaluation = create(:evaluation, :avec_mise_en_action)

      expect(described_class.new(evaluation).a_mise_en_action?).to be(true)
    end

    it "retourne false lorsqu'aucune mise en action n'est associée" do
      evaluation = create(:evaluation)

      expect(described_class.new(evaluation).a_mise_en_action?).to be(false)
    end
  end
end
