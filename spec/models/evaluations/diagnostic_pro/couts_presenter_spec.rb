# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::DiagnosticPro::CoutsPresenter do
  describe "#lettre" do
    it "mappe les scores vers la lettre" do
      presenter = described_class.new(synthese: { score_cout: :faible }, i18n: I18n)
      expect(presenter.lettre(:score_cout)).to eq("A")

      presenter = described_class.new(synthese: { score_cout: "faible" }, i18n: I18n)
      expect(presenter.lettre(:score_cout)).to eq("A")
    end
  end
end
