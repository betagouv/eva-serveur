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

  describe "#avec_restitution_globale" do
    it "expose les données dérivées du diagnostic entreprise via un objet testable" do
      diag = double(partie: double(synthese: { "pourcentage_risque" => 25 }), palier: "B - Bon")
      impact = double(synthese: { score_cout: "moyen" })

      restitution_globale = double(
        diag_risques_entreprise: diag,
        evaluation_impact_general: impact
      )

      presenter = described_class.new(double).avec_restitution_globale(restitution_globale)

      expect(presenter.pourcentage_risque).to eq(25)
      expect(presenter.palier_risque).to eq("B - Bon")
      expect(presenter.affiche_bilan_risque?).to be(true)
      expect(presenter.complet?).to be(true)
      expect(presenter.synthese_impact_general).to eq(score_cout: "moyen")
      expect(presenter.affiche_bilan?).to be(true)
    end

    it "garde pourcentage_risque à nil quand le diagnostic risques est absent" do
      restitution_globale = double(diag_risques_entreprise: nil, evaluation_impact_general: nil)
      presenter = described_class.new(double).avec_restitution_globale(restitution_globale)

      expect(presenter.pourcentage_risque).to be_nil
      expect(presenter.complet?).to be(false)
      expect(presenter.synthese_impact_general).to be_nil
      expect(presenter.affiche_bilan?).to be(false)
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

  describe Evaluations::DiagnosticPro::RisquesPresenter do
    describe "#palier" do
      it "retourne le palier A quand le pourcentage est très bas" do
        presenter = described_class.new(pourcentage_risque: 10)
        expect(presenter.palier).to eq("A - Très bon")
        expect(presenter.lettre).to eq("a")
      end

      it "retourne le palier D par défaut si le seuil est au-dessus des bornes" do
        presenter = described_class.new(pourcentage_risque: 999)
        expect(presenter.palier).to eq("D - Mauvais")
        expect(presenter.lettre).to eq("d")
      end
    end
  end
end
