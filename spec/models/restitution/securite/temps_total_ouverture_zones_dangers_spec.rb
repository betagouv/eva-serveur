# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::TempsTotalOuvertureZonesDangers do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#temps_total_ouverture_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }
      it { expect(restitution.temps_total_ouverture_zones_dangers).to eq({}) }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { danger: 'casque' },
               date: Time.local(2019, 10, 9, 10, 2))]
      end
      it { expect(restitution.temps_total_ouverture_zones_dangers).to eq('casque' => 60) }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'camion' }, date: Time.local(2019, 10, 9, 10, 4)),
         build(:evenement_qualification_danger,
               donnees: { danger: 'camion' }, date: Time.local(2019, 10, 9, 10, 6))]
      end
      it 'calcule les temps de chaque zone' do
        temps = restitution.temps_total_ouverture_zones_dangers
        expect(temps).to eq('casque' => 60, 'camion' => 120)
      end
      it 'retournes les zones par ordre alphabétique' do
        temps = restitution.temps_total_ouverture_zones_dangers
        expect(temps.keys).to eq(%w[camion casque])
      end
    end

    context 'plusieurs ouverture de la même zone' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'd1' }, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'd1' }, date: Time.local(2019, 10, 9, 10, 4))]
      end
      it { expect(restitution.temps_bonnes_qualifications_dangers).to eq('d1' => 120) }
    end

    context 'quand on ne finit pas par une qualification' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1))]
      end

      it { expect(restitution.temps_total_ouverture_zones_dangers).to eq({}) }
    end
  end
end
