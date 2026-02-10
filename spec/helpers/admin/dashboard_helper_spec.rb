require "rails_helper"

RSpec.describe Admin::DashboardHelper do
  describe "#eva_pro_locals" do
    let(:structure) { instance_double(Structure) }
    let(:opco_financeur) { instance_double(Opco) }
    let(:compte) { instance_double(Compte, structure: structure) }
    let(:ability) { instance_double(Ability) }
    let(:campagnes) { [ instance_double(Campagne) ] }
    let(:evaluations) { [ instance_double(Evaluation) ] }
    let(:actualites) { [ instance_double(Actualite) ] }
    let(:evaluation) { instance_double(Evaluation, id: 123) }
    let(:restitution) { instance_double(Restitution::Globale) }

    before do
      allow(structure).to receive(:opco_financeur).and_return(opco_financeur)
      allow(Evaluation).to receive(:au_moins_une_reponse_pour_structure?)
        .with(structure)
        .and_return(true)
    end

    context "quand une derniere evaluation complete est disponible" do
      before do
        allow(helper).to receive(:derniere_evaluation_complete)
          .with(structure, ability)
          .and_return(evaluation)
        allow(FabriqueRestitution).to receive(:restitution_globale)
          .with(evaluation)
          .and_return(restitution)
      end

      it "retourne les locals avec la restitution" do
        cinq_completes = [ instance_double(Evaluation) ]
        result = helper.eva_pro_locals(
          campagnes: campagnes,
          evaluations: evaluations,
          cinq_dernieres_evaluations_completes: cinq_completes,
          actualites: actualites,
          compte: compte,
          ability: ability
        )

        expect(result).to include(
          campagnes: campagnes,
          evaluations: evaluations,
          cinq_dernieres_evaluations_completes: cinq_completes,
          actualites: actualites,
          opco: opco_financeur,
          structure: structure,
          premiere_reponse_complete: true,
          derniere_evaluation_complete: evaluation,
          restitution_globale: restitution
        )
      end
    end

    context "quand aucune evaluation complete n'est disponible" do
      before do
        allow(helper).to receive(:derniere_evaluation_complete)
          .with(structure, ability)
          .and_return(nil)
      end

      it "retourne les locals sans restitution" do
        result = helper.eva_pro_locals(
          campagnes: campagnes,
          evaluations: evaluations,
          cinq_dernieres_evaluations_completes: [],
          actualites: actualites,
          compte: compte,
          ability: ability
        )

        expect(result[:restitution_globale]).to be_nil
      end
    end
  end

  describe "#eva_locals" do
    let(:campagnes) { [ instance_double(Campagne) ] }
    let(:evaluations) { [ instance_double(Evaluation) ] }
    let(:actualites) { [ instance_double(Actualite) ] }

    it "retourne les locals attendus" do
      expect(helper.eva_locals(
        campagnes: campagnes,
        evaluations: evaluations,
        actualites: actualites
      )).to eq(
        campagnes: campagnes,
        evaluations: evaluations,
        actualites: actualites
      )
    end
  end

  describe "#derniere_evaluation_complete" do
    let(:structure) { create(:structure_locale) }
    let(:compte) { create(:compte_admin, structure: structure) }
    let(:ability) { Ability.new(compte) }
    let(:parcours_type) { create(:parcours_type, type_de_programme: :diagnostic_entreprise) }
    let(:campagne) { create(:campagne, compte: compte, parcours_type: parcours_type) }
    let(:evaluation_old) { create(:evaluation, campagne: campagne, created_at: 2.days.ago) }
    let(:evaluation_new) { create(:evaluation, campagne: campagne, created_at: 1.day.ago) }

    before do
      allow(Evaluation).to receive(:accessible_by).with(ability).and_return(Evaluation)
      [ evaluation_old, evaluation_new ].each do |evaluation|
        situation = create(:situation)
        partie = create(:partie, evaluation: evaluation, situation: situation)
        create(:evenement_reponse,
               partie: partie,
               donnees: { "reponse" => "ok" },
               session_id: partie.session_id)
      end
    end

    context "avec plusieurs evaluations repondues" do
      it "retourne la plus recente" do
        result = helper.send(:derniere_evaluation_complete, structure, ability)

        expect(result).to eq(evaluation_new)
      end
    end
  end

  describe "#lettre_risque_pour" do
    let(:evaluation) { instance_double(Evaluation, id: 1) }
    let(:diag_risques) { instance_double(Restitution::DiagRisquesEntreprise, synthese: synthese) }
    let(:restitution) { instance_double(Restitution::Globale, diag_risques_entreprise: diag_risques) }

    before do
      allow(helper).to receive(:restitution_globale_pour).with(evaluation).and_return(restitution)
    end

    context "quand le pourcentage de risque est disponible" do
      let(:synthese) { { pourcentage_risque: 50 } }

      before do
        allow(helper).to receive(:palier_pourcentage_risque).with(50).and_return("C - Moyen")
        allow(helper).to receive(:palier_to_lettre).with("C - Moyen").and_return("c")
      end

      it "retourne la lettre du palier en majuscule" do
        expect(helper.send(:lettre_risque_pour, evaluation)).to eq("C")
      end
    end

    context "quand le pourcentage de risque est absent" do
      let(:synthese) { { pourcentage_risque: nil } }

      it "retourne nil" do
        expect(helper.send(:lettre_risque_pour, evaluation)).to be_nil
      end
    end
  end

  describe "#lettre_couts_pour" do
    let(:evaluation) { instance_double(Evaluation, id: 1) }
    let(:impact_general) { instance_double(Restitution::EvaluationImpactGeneral, synthese: synthese) }
    let(:restitution) { instance_double(Restitution::Globale, evaluation_impact_general: impact_general) }

    before do
      allow(helper).to receive(:restitution_globale_pour).with(evaluation).and_return(restitution)
    end

    context "quand le score cout est disponible" do
      let(:synthese) { { score_cout: "fort" } }

      before do
        allow(helper).to receive(:palier_score_cout).with("fort").and_return("D - Mauvais")
        allow(helper).to receive(:palier_to_lettre).with("D - Mauvais").and_return("d")
      end

      it "retourne la lettre du palier en majuscule" do
        expect(helper.send(:lettre_couts_pour, evaluation)).to eq("D")
      end
    end

    context "quand le score cout est absent" do
      let(:synthese) { { score_cout: nil } }

      it "retourne nil" do
        expect(helper.send(:lettre_couts_pour, evaluation)).to be_nil
      end
    end
  end
end
