# frozen_string_literal: true

require 'rails_helper'

describe Restitution::AvecEntrainement do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::AvecEntrainement.new campagne, evenements }

  describe '#temps_entrainement' do
    context "lorsqu'il est terminé" do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 7))]
      end

      it { expect(restitution.temps_entrainement).to eq 5.minutes }
    end

    context "lorsqu'il n'est pas terminé" do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: Time.local(2019, 10, 9, 10, 4))]
      end

      it { expect(restitution.temps_entrainement).to eq 2.minutes }
    end

    context 'ne prend pas en compte le temps de la situation' do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: Time.local(2019, 10, 9, 10, 4)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 4)),
         build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 6)),
         build(:evenement_identification_danger)]
      end

      it { expect(restitution.temps_entrainement).to eq 2.minutes }
    end
  end
end
