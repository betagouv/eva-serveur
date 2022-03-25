# frozen_string_literal: true

require 'rails_helper'

describe FabriqueRestitution do
  describe '#restitution_globale' do
    let(:situation) { create :situation_inventaire }
    let(:campagne) { create :campagne }
    let(:evaluation) { create :evaluation, campagne: campagne }
    let!(:partie) { create :partie, evaluation: evaluation, situation: situation }

    before do
      campagne.situations_configurations.create situation: situation
      create(:evenement_demarrage, partie: partie)
    end

    it "instancie les restitution des parties de l'évaluation" do
      restitutions = FabriqueRestitution.restitution_globale(evaluation).restitutions
      expect(restitutions.map(&:partie)).to eq [partie]
    end

    context 'instancie uniquement les parties présentes dans la campagne' do
      let(:situation_intrue) { create :situation_tri }
      let!(:partie_intrue) { create :partie, evaluation: evaluation, situation: situation_intrue }

      before do
        create(:evenement_demarrage, partie: partie_intrue)
      end

      it { expect(FabriqueRestitution.restitution_globale(evaluation).restitutions.count).to eq 1 }
    end

    context "quand il n'y a pas d'évenement pour une partie, n'instancie pas la restitution" do
      let(:situation2) { create :situation_controle }
      let!(:partie_sans_evenement) { create :partie, evaluation: evaluation, situation: situation2 }

      before do
        campagne.situations_configurations.create situation: situation2
      end

      it do
        restitutions = FabriqueRestitution.restitution_globale(evaluation).restitutions
        expect(restitutions.map(&:partie)).to eq [partie]
      end
    end
  end
end
