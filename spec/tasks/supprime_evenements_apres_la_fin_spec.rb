# frozen_string_literal: true

require 'rails_helper'

describe 'nettoyage:supprime_evenements_apres_la_fin' do
  include_context 'rake'

  let(:situation) { create :situation_livraison }
  let!(:partie) { create :partie, situation: situation }

  context 'sans événement après la fin' do
    let!(:evenements) { [create(:evenement_fin_situation, partie: partie)] }

    it do
      expect { subject.invoke }.to_not(change { Evenement.count })
    end
  end

  context 'avec événements après la fin' do
    let!(:evenements) do
      [create(:evenement_fin_situation, partie: partie, date: 1.day.ago),
       create(:evenement_piece_bien_placee, partie: partie, date: 1.day.from_now)]
    end

    it do
      expect { subject.invoke }.to(change { Evenement.count }.by(-1))
      expect(Evenement.first.nom).to eq 'finSituation'
    end
  end

  context 'sans événement fin' do
    let!(:evenements) { [create(:evenement_piece_bien_placee, partie: partie)] }

    it do
      expect { subject.invoke }.to_not(change { Evenement.count })
    end
  end

  context 'regroupe par partie' do
    let(:autre_partie) { create :partie, situation: situation, session_id: SecureRandom.uuid }
    let!(:evenement_fin) { create(:evenement_fin_situation, partie: partie, date: 1.day.ago) }
    let!(:evenement_recent_autre) do
      create(:evenement_piece_bien_placee, partie: autre_partie, date: 1.day.from_now)
    end

    it do
      expect { subject.invoke }.to_not(change { Evenement.count })
    end
  end
end
