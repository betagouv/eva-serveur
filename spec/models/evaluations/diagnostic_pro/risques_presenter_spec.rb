# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::DiagnosticPro::RisquesPresenter do
  describe "#palier" do
    it "retourne le palier A quand le pourcentage est très bas" do
      presenter = described_class.new(pourcentage_risque: 10)
      expect(presenter.palier).to eq("A")
    end

    it "retourne le palier C quand le pourcentage est égale à 50" do
      presenter = described_class.new(pourcentage_risque: 50)
      expect(presenter.palier).to eq("C")
    end

    it "retourne le palier D quand le pourcentage est supérieur 50" do
      presenter = described_class.new(pourcentage_risque: 51)
      expect(presenter.palier).to eq("D")
    end

    it "retourne le palier D quand le pourcentage est supérieur 75" do
      presenter = described_class.new(pourcentage_risque: 76)
      expect(presenter.palier).to eq("D")
    end
  end
end
