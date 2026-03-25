# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::DiagnosticPro::CoutsPresenter do
  describe "#palier_score_cout" do
    it "mappe les scores vers les paliers attendus" do
      presenter = described_class.new(synthese: {}, i18n: I18n)

      expect(presenter.palier_score_cout("faible")).to eq("A - Très bon")
      expect(presenter.palier_score_cout("moyen")).to eq("B - Bon")
      expect(presenter.palier_score_cout("fort")).to eq("C - Moyen")
      expect(presenter.palier_score_cout("tres_fort")).to eq("D - Mauvais")
      expect(presenter.palier_score_cout("inconnu")).to eq("D - Mauvais")
    end
  end

  describe "#score_to_lettre" do
    it "mappe les scores vers des lettres (pile flèches)" do
      presenter = described_class.new(synthese: {}, i18n: I18n)

      expect(presenter.score_to_lettre("faible")).to eq("a")
      expect(presenter.score_to_lettre("moyen")).to eq("b")
      expect(presenter.score_to_lettre("fort")).to eq("c")
      expect(presenter.score_to_lettre("tres_fort")).to eq("d")
    end
  end
end
