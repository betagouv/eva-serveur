# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::TempsMotsFrancais do
  let(:metrique_temps_mots_francais) do
    described_class.new.calcule(evenements_decores(evenements, :maintenance), [])
  end

  describe '#metrique metrique_moyenne_mots_francais' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end

      it { expect(metrique_temps_mots_francais).to eq [] }
    end

    context "avec deux événements d'identification mot français correcte" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot,
                donnees: { type: 'neutre', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 950_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'neutre', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 960_000)),
          build(:evenement_apparition_mot,
                donnees: { type: 'neutre', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 22, 950_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'neutre', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 22, 970_000))
        ]
      end

      it { expect(metrique_temps_mots_francais).to eq [ 0.01, 0.02 ] }
    end

    context "avec un événement d'identification non mot correcte" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 950_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 960_000))
        ]
      end

      it { expect(metrique_temps_mots_francais).to eq [] }
    end
  end
end
