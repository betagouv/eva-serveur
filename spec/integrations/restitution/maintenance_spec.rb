require 'rails_helper'

describe Restitution::Maintenance, type: :integration do
  context 'Calcule le score de deux parties et attend deux résultats différents' do
    let(:situation) { create :situation_maintenance }

    let(:partie1) { create :partie, situation: situation }
    let(:restitution1) { FabriqueRestitution.instancie partie1 }

    before do
      create(:evenement_demarrage,
             partie: partie1,
             date: Time.zone.local(2019, 10, 9, 10, 1, 20))
      create(:evenement_apparition_mot,
             partie: partie1,
             donnees: { 'mot' => 'revu', 'type' => 'neutre' },
             date: Time.zone.local(2019, 10, 9, 10, 1, 21))
    end

    it do
      expect(restitution1.score_ccf).to eq(0)
    end
  end
end
