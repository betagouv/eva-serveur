# frozen_string_literal: true

require 'rails_helper'

describe CreeEvenementAction do
  let(:evaluation) { create :evaluation }
  let(:situation) { create :situation_securite }
  let!(:demarrage) { create :evenement_demarrage, partie: partie }
  let(:partie) { create :partie, situation: situation, evaluation: evaluation }

  context 'avec un événement quelconque' do
    let(:evenement) { build :evenement_abandon }
    it "sauve l'évenement mais ne persiste pas les métriques" do
      expect { described_class.new(partie, evenement).call }
        .not_to have_enqueued_job(PersisteMetriquesPartieJob)
      expect(evenement).to be_persisted
    end
  end

  context 'avec un événement fin' do
    let(:evenement_fin) { build :evenement_fin_situation }

    it 'ne persiste pas les métriques de la partie quand il ne se sauve pas' do
      expect do
        expect(evenement_fin).to receive(:save).and_return(false)
        described_class.new(partie, evenement_fin).call
      end.not_to have_enqueued_job(PersisteMetriquesPartieJob)
    end

    it 'persiste les métriques de la partie quand il se sauve' do
      expect do
        described_class.new(partie, evenement_fin).call
      end.to have_enqueued_job(PersisteMetriquesPartieJob).exactly(1)
    end
  end
end
