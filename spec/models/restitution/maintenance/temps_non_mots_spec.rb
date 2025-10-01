require 'rails_helper'

describe Restitution::Maintenance::TempsNonMots do
  let(:metrique_temps_non_mots) do
    described_class.new.calcule(evenements_decores(evenements, :maintenance), [])
  end

  describe '#metrique metrique_temps_non_mots' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end

      it { expect(metrique_temps_non_mots).to eq [] }
    end

    context "avec un événement d'identification non-mot correct" do
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

      it { expect(metrique_temps_non_mots).to eq [ 0.01 ] }
    end

    context "avec un événement d'identification non-mot incorrect" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 250_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 260_000))
        ]
      end

      it { expect(metrique_temps_non_mots).to eq [] }
    end

    context "avec un événement d'identification sans identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot, donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                                           date: Time.zone.local(2019, 10, 9, 10, 1, 21, 250_000))
        ]
      end

      it { expect(metrique_temps_non_mots).to eq [] }
    end

    context "avec un événement d'identification non-mot non réponse" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 250_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 260_000))
        ]
      end

      it { expect(metrique_temps_non_mots).to eq [] }
    end

    context "avec deux événements d'identification non-mot correct et un incorrect" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 250_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 260_000)),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 650_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'francais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 21, 960_000)),
          build(:evenement_apparition_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 22, 100_000)),
          build(:evenement_identification_mot,
                donnees: { type: 'non-mot', reponse: 'pasfrancais' },
                date: Time.zone.local(2019, 10, 9, 10, 1, 23, 960_000))
        ]
      end

      it 'ne prend en compte que les idenfifications correctes' do
        expect(metrique_temps_non_mots).to eq [ 0.01, 1.86 ]
      end
    end
  end
end
