# frozen_string_literal: true

require 'rails_helper'

describe Restitution::AvecEntrainement::TempsEntrainement do
  let(:metrique_temps_entrainement) do
    described_class.new.calcule([], evenements)
  end

  describe '#temps_entrainement' do
    context 'sans entrainement' do
      let(:evenements) { [] }

      it { expect(metrique_temps_entrainement).to be_nil }
    end

    context 'avec un seul événement' do
      let(:evenements) do
        [ build(:evenement_demarrage_entrainement, date: Time.zone.local(2019, 10, 9, 10, 2)) ]
      end

      it { expect(metrique_temps_entrainement).to eq 0.minutes }
    end

    context "d'un entrainement complet" do
      let(:evenements) do
        [ build(:evenement_demarrage_entrainement, date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger, date: Time.zone.local(2019, 10, 9, 10, 7)) ]
      end

      it { expect(metrique_temps_entrainement).to eq 5.minutes }
    end
  end
end
