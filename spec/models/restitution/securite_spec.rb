# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#termine?' do
    context 'aucun danger qualifié' do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end
      it { expect(restitution).to_not be_termine }
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
      it { expect(restitution).to_not be_termine }
    end
  end

  describe '#delai_ouvertures_zones_dangers et #delai_moyen_ouvertures_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }
      it { expect(restitution.delai_ouvertures_zones_dangers).to eq [] }
      it { expect(restitution.delai_moyen_ouvertures_zones_dangers).to eq nil }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1))]
      end
      it { expect(restitution.delai_ouvertures_zones_dangers).to eq [60] }
      it { expect(restitution.delai_moyen_ouvertures_zones_dangers).to eq 60 }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd2' }, date: Time.local(2019, 10, 9, 10, 4))]
      end
      it { expect(restitution.delai_ouvertures_zones_dangers).to eq [60, 120] }
      it { expect(restitution.delai_moyen_ouvertures_zones_dangers).to eq 90 }
    end

    context 'ignore les zones non dangers ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: {}, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 3))]
      end
      it { expect(restitution.delai_ouvertures_zones_dangers).to eq [180] }
    end

    context 'quand on ne finit pas par une identification' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2))]
      end
      it { expect(restitution.delai_ouvertures_zones_dangers).to eq [60] }
    end
  end

  describe '#nombre_reouverture_zone_sans_danger' do
    context 'sans réouverture' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 0 }
    end

    context 'avec une réouverture' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 1 }
    end

    context "avec une autre réouverture d'une zone avec danger" do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 1 }
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de sécurité" do
      let(:situation) { create :situation_inventaire }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it do
        expect(restitution).to receive(:nombre_reouverture_zone_sans_danger).and_return 1
        expect(restitution).to receive(:nombre_bien_qualifies).and_return 2
        expect(restitution).to receive(:nombre_dangers_bien_identifies).and_return 3
        expect(restitution).to receive(:nombre_retours_deja_qualifies).and_return 4
        expect(restitution).to receive(:nombre_dangers_bien_identifies_avant_aide_1).and_return 5
        expect(restitution).to receive(:attention_visuo_spatiale).and_return Competence::APTE
        expect(restitution).to receive(:delai_ouvertures_zones_dangers).and_return [1, 2]
        expect(restitution).to receive(:delai_moyen_ouvertures_zones_dangers).and_return 7
        expect(restitution).to receive(:temps_entrainement).and_return 8
        expect(restitution).to receive(:temps_total).and_return 9
        expect(restitution).to receive(:nombre_rejoue_consigne).and_return 10
        expect(restitution).to receive(:nombre_dangers_mal_identifies).and_return 1
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_reouverture_zone_sans_danger']).to eq 1
        expect(partie.metriques['nombre_bien_qualifies']).to eq 2
        expect(partie.metriques['nombre_dangers_bien_identifies']).to eq 3
        expect(partie.metriques['nombre_retours_deja_qualifies']).to eq 4
        expect(partie.metriques['nombre_dangers_bien_identifies_avant_aide_1']).to eql 5
        expect(partie.metriques['attention_visuo_spatiale']).to eql 'apte'
        expect(partie.metriques['delai_ouvertures_zones_dangers']).to eql [1, 2]
        expect(partie.metriques['delai_moyen_ouvertures_zones_dangers']).to eql 7
        expect(partie.metriques['temps_entrainement']).to eql 8
        expect(partie.metriques['temps_total']).to eql 9
        expect(partie.metriques['nombre_rejoue_consigne']).to eql 10
        expect(partie.metriques['nombre_dangers_mal_identifies']).to eql 1
      end
    end
  end
end
