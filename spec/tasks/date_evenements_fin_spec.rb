# frozen_string_literal: true

require 'rails_helper'

describe 'nettoyage:date_evenements_fin' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  let(:situation) { create :situation_livraison }
  let!(:partie) { create :partie, situation: situation }
  let(:evenement_fin) { create(:evenement_fin_situation, partie: partie, date: date_fin) }
  let(:evenement_precedent) do
    create(:evenement, partie: partie, date: 2.days.ago.beginning_of_day)
  end
  let!(:evenements) { [evenement_precedent, evenement_fin] }

  before do
    allow(logger).to receive :info
    subject.invoke
  end

  context 'événement avec date unique' do
    let(:date_fin) { 1.day.ago.beginning_of_day }

    it { expect(evenement_fin.reload.date).to eq date_fin }
  end

  context "la date de fin égale à l'événement précédent" do
    let(:date_fin) { evenement_precedent.date }

    it do
      expect(evenement_fin.reload.date - evenement_precedent.reload.date).to eq(0.001)
    end
  end

  context 'même date mais sans événement fin' do
    let(:autre_evenement) { create(:evenement, partie: partie, date: evenement_precedent.date) }
    let!(:evenements) { [evenement_precedent, autre_evenement] }

    it { expect(autre_evenement.reload.date).to eq evenement_precedent.date }
  end

  context 'même date, deux parties différentes' do
    let(:date_fin) { evenement_autre_partie.date }

    let(:autre_partie) { create :partie, situation: situation }
    let(:evenement_autre_partie) do
      create(:evenement, partie: autre_partie, date: 3.days.ago.beginning_of_day)
    end

    let!(:evenements) { [evenement_autre_partie, evenement_fin] }

    it { expect(evenement_fin.reload.date).to eq date_fin }
  end

  context 'trie les événements par date' do
    let(:date_fin) { evenement_precedent.date }
    let(:evenement_le_plus_tot) { create(:evenement, partie: partie, date: date_fin - 1.minute) }
    let!(:evenements) { [evenement_precedent, evenement_fin, evenement_le_plus_tot] }

    it do
      expect(evenement_fin.reload.date - evenement_precedent.reload.date).to eq(0.001)
    end
  end
end
