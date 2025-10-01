require 'rails_helper'

describe Restitution::Maintenance do
  let(:evenements) { [] }
  let(:campagne) { Campagne.new }
  let(:restitution) { described_class.new campagne, evenements }

  describe '#persiste' do
    context "persiste l'ensemble des données de maintenance" do
      let(:situation) { create :situation_maintenance }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:evenements) do
        [ build(:evenement_demarrage, partie: partie) ]
      end

      it do
        expect(restitution).to receive(:nombre_non_reponses).and_return 2
        expect(restitution).to receive(:nombre_bonnes_reponses_non_mot).and_return 20
        expect(restitution).to receive(:temps_moyen_mots_francais).and_return 0.789
        expect(restitution).to receive(:temps_moyen_non_mots).and_return 1.5
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_non_reponses']).to eq 2
        expect(partie.metriques['nombre_bonnes_reponses_non_mot']).to eq 20
        expect(partie.metriques['temps_moyen_mots_francais']).to eq 0.789
        expect(partie.metriques['temps_moyen_non_mots']).to eq 1.5
      end
    end
  end
end
