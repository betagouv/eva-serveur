# frozen_string_literal: true

require "rails_helper"

RSpec.describe SynthesesEvaproPourIndex do
  describe ".pour" do
    let(:evaluation) { create(:evaluation) }
    let(:collection) { Evaluation.where(id: evaluation.id) }

    context "avec une collection vide" do
      let(:collection) { Evaluation.none }

      it "retourne un hash vide" do
        expect(described_class.pour(collection)).to eq({})
      end
    end

    context "sans parties pour les situations Eva Pro" do
      it "retourne un hash avec des valeurs nil pour cette évaluation" do
        resultat = described_class.pour(collection)

        expect(resultat.keys).to eq([ evaluation.id ])
        expect(resultat[evaluation.id]).to eq(pourcentage_risque: nil, score_cout: nil)
      end
    end

    context "avec une partie diag_risques_entreprise ayant une synthese" do
      let(:situation_diag) do
        create(:situation, nom_technique: Situation::DIAG_RISQUES_ENTREPRISE)
      end
      let!(:partie_diag) do
        create(:partie,
               evaluation: evaluation,
               situation: situation_diag,
               synthese: { "pourcentage_risque" => 25 })
      end

      it "remplit pourcentage_risque pour cette évaluation" do
        resultat = described_class.pour(collection)

        expect(resultat[evaluation.id][:pourcentage_risque]).to eq(25)
        expect(resultat[evaluation.id][:score_cout]).to be_nil
      end
    end

    context "avec une partie evaluation_impact_general ayant une synthese" do
      let(:situation_impact) do
        create(:situation, nom_technique: Situation::EVALUATION_IMPACT_GENERAL)
      end
      let!(:partie_impact) do
        create(:partie,
               evaluation: evaluation,
               situation: situation_impact,
               synthese: { "score_cout" => "fort" })
      end

      it "remplit score_cout pour cette évaluation" do
        resultat = described_class.pour(collection)

        expect(resultat[evaluation.id][:pourcentage_risque]).to be_nil
        expect(resultat[evaluation.id][:score_cout]).to eq("fort")
      end
    end

    context "avec les deux types de parties" do
      let(:situation_diag) do
        create(:situation, nom_technique: Situation::DIAG_RISQUES_ENTREPRISE)
      end
      let(:situation_impact) do
        create(:situation, nom_technique: Situation::EVALUATION_IMPACT_GENERAL)
      end
      let!(:partie_diag) do
        create(:partie,
               evaluation: evaluation,
               situation: situation_diag,
               synthese: { "pourcentage_risque" => 10 })
      end
      let!(:partie_impact) do
        create(:partie,
               evaluation: evaluation,
               situation: situation_impact,
               synthese: { "score_cout" => "moyen" })
      end

      it "retourne les deux indicateurs pour l’évaluation" do
        resultat = described_class.pour(collection)

        expect(resultat[evaluation.id]).to eq(pourcentage_risque: 10, score_cout: "moyen")
      end
    end

    context "avec plusieurs évaluations de la collection" do
      let(:autre_evaluation) { create(:evaluation) }
      let(:collection) { Evaluation.where(id: [ evaluation.id, autre_evaluation.id ]) }
      let(:situation_diag) do
        create(:situation, nom_technique: Situation::DIAG_RISQUES_ENTREPRISE)
      end
      let(:situation_impact) do
        create(:situation, nom_technique: Situation::EVALUATION_IMPACT_GENERAL)
      end

      before do
        create(:partie,
               evaluation: evaluation,
               situation: situation_diag,
               synthese: { "pourcentage_risque" => 34 })
        create(:partie,
               evaluation: autre_evaluation,
               situation: situation_impact,
               synthese: { "score_cout" => "faible" })
      end

      it "retourne les synthèses pour chaque évaluation sans mélange" do
        resultat = described_class.pour(collection)

        expect(resultat[evaluation.id]).to eq(pourcentage_risque: 34, score_cout: nil)
        expect(resultat[autre_evaluation.id]).to eq(pourcentage_risque: nil, score_cout: "faible")
      end
    end
  end
end
