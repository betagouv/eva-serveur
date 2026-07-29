# frozen_string_literal: true

require "rails_helper"

RSpec.describe EvaluationsEvapro::ImpactsPresenter do
  describe "#complet?" do
    it "retourne true quand evaluation_impact_general est présent" do
      presenter = described_class.new(
        evaluation_impact_general: double(synthese: {}),
        evaluation_id: "id"
      )

      expect(presenter.complet?).to be(true)
    end

    it "retourne false quand evaluation_impact_general est absent" do
      presenter = described_class.new(
        evaluation_impact_general: nil,
        evaluation_id: "id"
      )

      expect(presenter.complet?).to be(false)
    end
  end

  describe "#incomplet_url" do
    it "construit une URL stable à partir de la base URL" do
      presenter = described_class.new(
        evaluation_impact_general: nil,
        evaluation_id: "e123"
      )

      expect(presenter.incomplet_url("https://example.test")).to eq(
        "https://example.test/evaluation-impact?evaluation_id=e123"
      )
    end
  end
end
