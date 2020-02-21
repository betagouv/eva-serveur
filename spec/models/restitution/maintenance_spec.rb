# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance do
  describe '#persiste' do
    context "persiste l'ensemble des données de maintenance" do
      let(:campagne) { Campagne.new }
      let(:restitution) { described_class.new campagne, evenements }

      let(:situation) { create :situation_maintenance }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:evenements) do
        [build(:evenement_demarrage)]
      end

      it do
        expect(restitution).to receive(:nombre_non_reponses).and_return 2
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_non_reponses']).to eq 2
      end
    end
  end
end
