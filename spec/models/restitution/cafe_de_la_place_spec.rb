# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CafeDeLaPlace do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) { create :situation }
  let(:campagne) { build :campagne }
  let(:restitution) do
    described_class.new(campagne,
                        [
                          build(:evenement_demarrage, partie: partie),
                          build(:evenement_reponse, partie: partie),
                          build(:evenement_reponse, donnees: { succes: true }, partie: partie)
                        ])
  end

  describe '#efficience' do
    it 'retourne nil' do
      expect(restitution.efficience).to be_nil
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de la partie" do
      it do
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_reponses']).to eq 2
        expect(partie.metriques['score']).to eq 1
      end
    end
  end
end