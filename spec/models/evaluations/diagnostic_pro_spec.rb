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

  describe "#with_restitution_globale" do
    it "expose les données dérivées du diagnostic entreprise via un objet testable" do
      diag = double(partie: double(synthese: { "pourcentage_risque" => 25 }))
      impact = double(synthese: { score_cout: "moyen" })

      restitution_globale = double(
        diag_risques_entreprise: diag,
        evaluation_impact_general: impact
      )

      presenter = described_class.new(double).with_restitution_globale(restitution_globale)

      expect(presenter.pourcentage_risque).to eq(25)
      expect(presenter.complet?).to be(true)
      expect(presenter.synthese_impact_general).to eq(score_cout: "moyen")
      expect(presenter.affiche_bilan?).to be(true)
    end

    it "garde pourcentage_risque à nil quand le diagnostic risques est absent" do
      restitution_globale = double(diag_risques_entreprise: nil, evaluation_impact_general: nil)
      presenter = described_class.new(double).with_restitution_globale(restitution_globale)

      expect(presenter.pourcentage_risque).to be_nil
      expect(presenter.complet?).to be(false)
      expect(presenter.synthese_impact_general).to be_nil
      expect(presenter.affiche_bilan?).to be(false)
    end
  end
end

