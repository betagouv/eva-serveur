# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire do
  describe "#evapro?" do
    it "retourne false" do
      expect(described_class.new(double).evapro?).to be(false)
    end
  end
end

