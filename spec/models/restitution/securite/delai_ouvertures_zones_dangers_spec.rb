# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::DelaiOuverturesZonesDangers do
  let(:metrique_delai_ouvertures_zones_dangers) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#delai_ouvertures_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }

      it { expect(metrique_delai_ouvertures_zones_dangers).to eq [] }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.zone.local(2019, 10, 9, 10, 1)) ]
      end

      it { expect(metrique_delai_ouvertures_zones_dangers).to eq [ 60.0 ] }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd2' }, date: Time.zone.local(2019, 10, 9, 10, 4, 1.5)) ]
      end

      it { expect(metrique_delai_ouvertures_zones_dangers).to eq [ 60.0, 121.5 ] }
    end

    context 'ignore les zones non dangers ouverts' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: {}, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.zone.local(2019, 10, 9, 10, 3)) ]
      end

      it { expect(metrique_delai_ouvertures_zones_dangers).to eq [ 180 ] }
    end

    context 'quand on ne finit pas par une identification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.zone.local(2019, 10, 9, 10, 2)) ]
      end

      it { expect(metrique_delai_ouvertures_zones_dangers).to eq [ 60 ] }
    end
  end
end
