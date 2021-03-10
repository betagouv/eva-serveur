# frozen_string_literal: true

require 'rails_helper'

describe CreeEvenementAction do
  let(:evaluation) { create :evaluation }
  let(:situation) { create :situation_securite }
  let!(:demarrage) { create :evenement_demarrage, partie: partie }
  let(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:restitution) { double }

  before do
    allow(FabriqueRestitution).to receive(:instancie).with(partie).and_return restitution
  end

  context "sauve l'évenement" do
    let(:evenement) { build :evenement_abandon }
    before { described_class.new(partie, evenement).call }
    it { expect(evenement).to be_persisted }
  end

  context 'avec un événement fin' do
    let(:evenement_fin) { build :evenement_fin_situation }

    it 'ne persiste pas la restitution quand il ne se sauve pas' do
      expect(evenement_fin).to receive(:save).and_return(false)
      expect(restitution).to_not receive(:persiste)
      described_class.new(partie, evenement_fin).call
    end

    it 'persiste la restitution quand il se sauve' do
      expect(restitution).to receive(:persiste)
      described_class.new(partie, evenement_fin).call
    end
  end

  context 'qui ne termine pas la sécurité' do
    let(:evenement_identification_danger) { build :evenement_identification_danger }

    it do
      expect(Restitution::Securite).to_not receive(:new)
      described_class.new(partie, evenement_identification_danger).call
    end
  end
end
