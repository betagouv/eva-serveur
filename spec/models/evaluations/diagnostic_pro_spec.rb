# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::DiagnosticPro do
  describe "#opco" do
    it "retourne l'opco de la structure de la campagne" do
      opco = double
      structure = double(opco: opco, opco_financeur: double)
      compte = double(structure: structure)
      campagne = double(compte: compte)
      evaluation = double(campagne: campagne)

      expect(described_class.new(evaluation).opco).to eq(opco)
    end

    it "retourne nil quand la structure est absente" do
      compte = double(structure: nil)
      campagne = double(compte: compte)
      evaluation = double(campagne: campagne)

      expect(described_class.new(evaluation).opco).to be_nil
    end
  end

  describe "#restitution_pro" do
    it "expose les données dérivées du diagnostic entreprise via un objet testable" do
      diag = double(
        partie: double(synthese: { "pourcentage_risque" => 25 }, evenements: []),
        palier: "B"
      )
      impact = double(
        synthese: {
          score_cout: "moyen",
          score_strategie: "fort",
          score_numerique: "faible"
        },
        partie: double(evenements: [])
      )

      restitution_globale = double(
        diag_risques_entreprise: diag,
        evaluation_impact_general: impact,
        evaluation: double(complete?: true)
      )

      presenter = described_class.new(double).restitution_pro(restitution_globale)

      expect(presenter.pourcentage_risque).to eq(25)
      expect(presenter.palier_risque).to eq("B")
      expect(presenter.palier_bilan).to eq("A")
      expect(presenter.affiche_bilan_risque?).to be(true)
      expect(presenter.complet?).to be(true)
      expect(presenter.synthese_impact_general).to eq(
        score_cout: "moyen",
        score_strategie: "fort",
        score_numerique: "faible"
      )
    end

    it "garde pourcentage_risque à nil quand le diagnostic risques est absent" do
      restitution_globale = double(diag_risques_entreprise: nil, evaluation_impact_general: nil,
evaluation: double(complete?: false))
      presenter = described_class.new(double).restitution_pro(restitution_globale)

      expect(presenter.pourcentage_risque).to be_nil
      expect(presenter.palier_bilan).to be_nil
      expect(presenter.complet?).to be(false)
      expect(presenter.synthese_impact_general).to be_nil
    end
  end

  describe Evaluations::DiagnosticPro::ImpactsPresenter do
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
end
