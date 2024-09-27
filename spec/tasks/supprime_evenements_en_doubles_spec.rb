# frozen_string_literal: true

require 'rails_helper'

describe 'nettoyage:supprime_doublons_evenements' do
  include_context 'rake'

  let(:situation) { create :situation_livraison }
  let!(:partie) { create :partie, situation: situation }
  let(:logger) { RakeLogger.logger }

  before { allow(logger).to receive :info }

  context 'sans événement en double' do
    let!(:evenements) { [create(:evenement_fin_situation, partie: partie)] }

    it do
      expect(logger).to receive(:info).once
      expect { subject.invoke }.not_to(change(Evenement, :count))
    end
  end

  context 'avec deux événements en même position dans des parties differentes' do
    let!(:partie2) { create :partie, situation: situation }
    let!(:evenements) do
      [create(:evenement_fin_situation, partie: partie, position: 0),
       create(:evenement_piece_bien_placee, partie: partie, position: 1),
       create(:evenement_piece_bien_placee, partie: partie2, position: 1)]
    end

    it { expect { subject.invoke }.not_to(change(Evenement, :count)) }
  end

  context 'avec deux événements en double dans la même partie' do
    let!(:evenements) do
      [create(:evenement_fin_situation, partie: partie, position: 0),
       create(:evenement_piece_bien_placee, partie: partie, position: 1),
       create(:evenement_piece_bien_placee, partie: partie, position: 2)]
    end

    before do
      evenements[2].position = 1
      evenements[2].save(validate: false)
    end

    it do
      expect(logger).to receive(:info).twice
      expect { subject.invoke }.to(change(Evenement, :count).by(-1))
    end
  end
end
