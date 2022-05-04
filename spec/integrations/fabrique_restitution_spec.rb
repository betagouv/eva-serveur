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

    context 'quand une situation a été jouée 2 fois' do
      let(:situation_controle) { create :situation_controle }

      let!(:partie1) { create :partie, evaluation: evaluation, situation: situation_controle }
      let!(:partie2) { create :partie, evaluation: evaluation, situation: situation_controle }

      before do
        campagne.situations_configurations.create situation: situation_controle
      end

      context 'quand les 2 parties sont terminée' do
        before do
          create(:evenement_fin_situation, partie: partie1)
          create(:evenement_fin_situation, partie: partie2)
        end

        it 'utilise la première partie pour la restitution globale' do
          restitutions = FabriqueRestitution.restitution_globale(evaluation).restitutions
          expect(restitutions[1].partie).to eq partie1
        end
      end

      context 'quand une des parties est terminée' do
        before do
          create(:evenement_demarrage, partie: partie1)
          create(:evenement_fin_situation, partie: partie2)
        end

        it 'utilise cette partie pour la restitution globale' do
          restitutions = FabriqueRestitution.restitution_globale(evaluation).restitutions
          expect(restitutions[1].partie).to eq partie2
        end
      end

      context "quand aucune des parties n'est terminée" do
        before do
          create(:evenement_demarrage, partie: partie1)
          create(:evenement_demarrage, partie: partie2)
        end

        it 'utilise la première partie pour la restitution globale' do
          restitutions = FabriqueRestitution.restitution_globale(evaluation).restitutions
          expect(restitutions[1].partie).to eq partie1
        end
      end
    end
  end
end
