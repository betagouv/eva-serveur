# frozen_string_literal: true

require 'rails_helper'

describe CreeEvenementAction do
  let(:evaluation) { create :evaluation }
  let(:situation) { create :situation_securite }
  let(:demarrage) { build :evenement_demarrage }
  let(:partie) do
    create :partie, situation: situation, evaluation: evaluation,
                    evenements: [demarrage]
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
      expect(partie).to_not receive(:persiste_restitution)
      described_class.new(partie, evenement_fin).call
    end

    it 'persiste la restitution quand il se sauve' do
      expect(partie).to receive(:persiste_restitution)
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
