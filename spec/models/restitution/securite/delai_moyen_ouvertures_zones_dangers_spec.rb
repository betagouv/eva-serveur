# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::DelaiMoyenOuverturesZonesDangers do
  let(:metrique_delai_moyen_ouvertures_zones_dangers) do
    described_class.new(evenements_decores(evenements, :securite)).calcule
  end

  describe '#delai_moyen_ouvertures_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }
      it { expect(metrique_delai_moyen_ouvertures_zones_dangers).to eq nil }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1))]
      end
      it { expect(metrique_delai_moyen_ouvertures_zones_dangers).to eq 60.0 }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd2' }, date: Time.local(2019, 10, 9, 10, 4, 1))]
      end
      it { expect(metrique_delai_moyen_ouvertures_zones_dangers).to eq 90.5 }
    end
  end
end
