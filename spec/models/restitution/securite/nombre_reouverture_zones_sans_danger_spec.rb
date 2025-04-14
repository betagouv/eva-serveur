# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::NombreReouvertureZonesSansDanger do
  let(:metrique_nombre_reouverture_zones_sans_danger) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#nombre_reouverture_zones_sans_danger' do
    context 'sans réouverture' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })
        ]
      end

      it { expect(metrique_nombre_reouverture_zones_sans_danger).to eq 0 }
    end

    context 'avec une réouverture' do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }) ]
      end

      it { expect(metrique_nombre_reouverture_zones_sans_danger).to eq 1 }
    end

    context "avec une autre réouverture d'une zone avec danger" do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }) ]
      end

      it { expect(metrique_nombre_reouverture_zones_sans_danger).to eq 1 }
    end
  end
end
