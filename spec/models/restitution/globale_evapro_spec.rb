require 'rails_helper'

describe Restitution::GlobaleEvapro do
  let(:restitutions) { [ double ] }
  let(:restitutions_dernier_essai) { [] }
  let(:evaluation) { double }

  let(:restitution_globale) do
    described_class.new evaluation: evaluation,
      restitutions: restitutions,
      restitutions_dernier_essai: restitutions_dernier_essai
  end

  describe '#persiste' do
    let(:restitutions) { [] }
    let(:champs_persistes) { {
      completude: :complete
    } }
    let(:completude) { double }

    before do
      allow(evaluation).to receive(:id).and_return("un id")
      allow(completude).to receive(:calcule).and_return(:complete)
      allow(Restitution::Completude).to receive(:new).and_return(completude)
    end

    it do
      expect(evaluation).to receive(:update).with(champs_persistes)
      restitution_globale.persiste
    end
  end

  describe("#selectionne_derniere_restitution") do
    let(:restitution_classique) do
      instance_double(Restitution::Base,
        situation: build(:situation_inventaire))
    end
    let(:restitution_evapro_ancienne) do
      instance_double(Restitution::Base,
        situation: build(:situation, nom_technique: nom_technique))
    end
    let(:restitution_evapro_recente) do
      instance_double(Restitution::Base,
        situation: build(:situation, nom_technique: nom_technique))
    end
    let(:restitutions) do
      [ restitution_classique, restitution_evapro_ancienne ]
    end
    let(:restitutions_dernier_essai) do
      [ restitution_classique, restitution_evapro_recente ]
    end


    describe "#diag_risques_entreprise" do
      let(:nom_technique) { Situation::DIAG_RISQUES_ENTREPRISE }

      it "retourne la dernière restitution de la situation diagnostic entreprise" do
        expect(restitution_globale.diag_risques_entreprise).to eq(restitution_evapro_recente)
      end
    end

    describe "#evaluation_impact_general" do
      let(:nom_technique) { Situation::EVALUATION_IMPACT_GENERAL }

      it "retourne la dernière restitution de la situation impact général" do
        expect(restitution_globale.evaluation_impact_general).to eq(restitution_evapro_recente)
      end
    end
  end
end
