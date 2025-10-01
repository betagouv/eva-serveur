require 'rails_helper'

describe Restitution::Securite do
  let(:campagne) { Campagne.new }
  let(:restitution) { described_class.new campagne, evenements }

  describe '#termine?' do
    context 'aucun danger qualifié' do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end

      it { expect(restitution).not_to be_termine }
    end

    context 'tous les dangers qualifiés' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          Array.new(Restitution::Securite::ZONES_DANGER.count) do |index|
            build(:evenement_qualification_danger, donnees: { danger: "danger-#{index}" })
          end
        ].flatten
      end

      it { expect(restitution).to be_termine }
    end

    context "avec l'événement de fin de situation" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_fin_situation)
        ]
      end

      it { expect(restitution).to be_termine }
    end

    context 'ignore les requalifications de danger' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          Array.new(Restitution::Securite::ZONES_DANGER.count) do
            build(:evenement_qualification_danger, donnees: { danger: 'danger' })
          end
        ].flatten
      end

      it { expect(restitution).not_to be_termine }
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de sécurité" do
      let(:situation) { create :situation_securite }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:evenements) do
        [ build(:evenement_demarrage, partie: partie),
         build(:evenement_ouverture_zone, partie: partie, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, partie: partie, donnees: { zone: 'zone1' }) ]
      end

      it do
        expect(restitution).to receive(:nombre_reouverture_zones_sans_danger).and_return 1
        expect(restitution).to receive(:nombre_bien_qualifies).and_return 2
        expect(restitution).to receive(:nombre_dangers_bien_identifies).and_return 3
        expect(restitution).to receive(:nombre_retours_deja_qualifies).and_return 4
        expect(restitution).to receive(:nombre_dangers_bien_identifies_avant_aide1).and_return 5
        expect(restitution).to receive(:attention_visuo_spatiale).and_return Competence::APTE
        expect(restitution).to receive(:delai_ouvertures_zones_dangers).and_return [ 1, 2 ]
        expect(restitution).to receive(:delai_moyen_ouvertures_zones_dangers).and_return 7
        expect(restitution).to receive(:temps_entrainement).and_return 8
        expect(restitution).to receive(:temps_total).and_return 9
        expect(restitution).to receive(:nombre_dangers_mal_identifies).and_return 1
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_reouverture_zones_sans_danger']).to eq 1
        expect(partie.metriques['nombre_bien_qualifies']).to eq 2
        expect(partie.metriques['nombre_dangers_bien_identifies']).to eq 3
        expect(partie.metriques['nombre_retours_deja_qualifies']).to eq 4
        expect(partie.metriques['nombre_dangers_bien_identifies_avant_aide1']).to be 5
        expect(partie.metriques['attention_visuo_spatiale']).to eql 'apte'
        expect(partie.metriques['delai_ouvertures_zones_dangers']).to eql [ 1, 2 ]
        expect(partie.metriques['delai_moyen_ouvertures_zones_dangers']).to be 7
        expect(partie.metriques['temps_entrainement']).to be 8
        expect(partie.metriques['temps_total']).to be 9
        expect(partie.metriques['nombre_dangers_mal_identifies']).to be 1
      end
    end
  end
end
