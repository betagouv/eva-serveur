# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::TempsRechercheZonesDangers do
  let(:metrique_temps_recherche_zones_dangers) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#temps_recherche_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }

      it { expect(metrique_temps_recherche_zones_dangers).to eq({}) }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1))]
      end

      it { expect(metrique_temps_recherche_zones_dangers).to eq('casque' => 60) }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'camion' }, date: Time.zone.local(2019, 10, 9, 10, 4))]
      end

      it 'calcule les temps de recherche' do
        temps = metrique_temps_recherche_zones_dangers
        expect(temps).to eq('casque' => 60, 'camion' => 120)
      end

      it 'retournes les zones par ordre alphabétique' do
        temps = metrique_temps_recherche_zones_dangers
        expect(temps.keys).to eq(%w[camion casque])
      end
    end

    context 'quand on ne finit pas par une identification' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.zone.local(2019, 10, 9, 10, 2))]
      end

      it { expect(metrique_temps_recherche_zones_dangers).to eq('casque' => 60) }
    end
  end
end
