# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::TempsRechercheZonesDangers do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#temps_recherche_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }
      it { expect(restitution.temps_recherche_zones_dangers).to eq [nil, nil, nil, nil, nil] }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1))]
      end
      it { expect(restitution.temps_recherche_zones_dangers).to eq [nil, 60, nil, nil, nil] }
    end

    context 'deux zones danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'camion' }, date: Time.local(2019, 10, 9, 10, 4))]
      end
      it { expect(restitution.temps_recherche_zones_dangers).to eq [nil, 60, nil, 120, nil] }
    end

    context 'quand on ne finit pas par une identification' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2))]
      end

      it { expect(restitution.temps_recherche_zones_dangers).to eq [nil, 60, nil, nil, nil] }
    end
  end
end
