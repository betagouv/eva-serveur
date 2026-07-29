require 'rails_helper'

describe EvaluationEvapro do
  describe "#opco" do
    it "retourne l'opco de la structure de la campagne" do
      opco = double
      structure = double(opco: opco, opco_financeur: double)
      campagne = double(structure: structure)
      evaluation = described_class.new
      allow(evaluation).to receive(:campagne).and_return(campagne)

      expect(evaluation.opco).to eq(opco)
    end

    it "retourne nil quand la structure est absente" do
      campagne = double(structure: nil)
      evaluation = described_class.new
      allow(evaluation).to receive(:campagne).and_return(campagne)

      expect(evaluation.opco).to be_nil
    end
  end

  describe "#opco_financeur" do
    it "retourne l'opco_financeur de la structure de la campagne" do
      opco_financeur = double
      structure = double(opco_financeur: opco_financeur)
      campagne = double(structure: structure)
      evaluation = described_class.new
      allow(evaluation).to receive(:campagne).and_return(campagne)

      expect(evaluation.opco_financeur).to eq(opco_financeur)
    end
  end

  describe "#titre" do
    it "retourne le nom de la structure de la campagne" do
      structure = double(nom: "Ma structure")
      campagne = double(structure: structure)
      evaluation = described_class.new
      allow(evaluation).to receive(:campagne).and_return(campagne)

      expect(evaluation.titre).to eq("Ma structure")
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

      presenter = described_class.new.restitution_pro(restitution_globale)

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
      presenter = described_class.new.restitution_pro(restitution_globale)

      expect(presenter.pourcentage_risque).to be_nil
      expect(presenter.palier_bilan).to be_nil
      expect(presenter.complet?).to be(false)
      expect(presenter.synthese_impact_general).to be_nil
    end
  end
end
