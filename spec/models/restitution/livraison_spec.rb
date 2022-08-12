# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Livraison do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) { create :situation_livraison }
  let(:campagne) { build :campagne }
  let(:restitution) { described_class.new(campagne, [build(:evenement_demarrage, partie: partie)]) }

  describe '#efficience' do
    it 'retourne nil' do
      expect(restitution.efficience).to be_nil
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de livraison" do
      it do
        expect(restitution).to receive(:nombre_reponses_ccf).and_return 2
        expect(restitution).to receive(:nombre_reponses_numeratie).and_return 1
        expect(restitution).to receive(:nombre_reponses_syntaxe_orthographe).and_return 3
        expect(restitution).to receive(:score_numeratie).and_return 0.1
        expect(restitution).to receive(:score_ccf).and_return 0.2
        expect(restitution).to receive(:score_syntaxe_orthographe).and_return 0.3

        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_reponses_ccf']).to eq 2
        expect(partie.metriques['nombre_reponses_numeratie']).to eq 1
        expect(partie.metriques['nombre_reponses_syntaxe_orthographe']).to eq 3
        expect(partie.metriques['score_numeratie']).to eq 0.1
        expect(partie.metriques['score_ccf']).to eq 0.2
        expect(partie.metriques['score_syntaxe_orthographe']).to eq 0.3
      end
    end
  end
end
