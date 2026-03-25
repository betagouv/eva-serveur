# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluation::Context do
  describe "#pro?" do
    context "quand le parcours est diagnostic entreprise (Eva Pro)" do
      let(:evaluation) { create(:evaluation, :evapro) }

      it "retourne true" do
        expect(described_class.new(evaluation).pro?).to be(true)
      end
    end

    context "quand le parcours est diagnostic bénéficiaire" do
      let(:evaluation) { create(:evaluation, :diagnostic) }

      it "retourne false" do
        expect(described_class.new(evaluation).pro?).to be(false)
      end
    end

    context "quand le parcours est positionnement" do
      let(:evaluation) { create(:evaluation, :positionnement) }

      it "retourne false" do
        expect(described_class.new(evaluation).pro?).to be(false)
      end
    end
  end

  describe "#usage_beneficiaire?" do
    it "est l'inverse de pro? pour un diagnostic entreprise" do
      evaluation = create(:evaluation, :evapro)
      contexte = described_class.new(evaluation)

      expect(contexte.usage_beneficiaire?).to be(false)
      expect(contexte.pro?).to be(true)
    end

    it "est l'inverse de pro? pour un diagnostic classique" do
      evaluation = create(:evaluation, :diagnostic)
      contexte = described_class.new(evaluation)

      expect(contexte.usage_beneficiaire?).to be(true)
      expect(contexte.pro?).to be(false)
    end
  end

  describe "cohérence avec Evaluation" do
    it "aligne evapro? et context.pro?" do
      evapro_eval = create(:evaluation, :evapro)
      beneficiaire_eval = create(:evaluation, :diagnostic)

      expect(evapro_eval.evapro?).to eq(evapro_eval.context.pro?)
      expect(evapro_eval.evapro?).to be(true)

      expect(beneficiaire_eval.evapro?).to eq(beneficiaire_eval.context.pro?)
      expect(beneficiaire_eval.evapro?).to be(false)
    end
  end
end
