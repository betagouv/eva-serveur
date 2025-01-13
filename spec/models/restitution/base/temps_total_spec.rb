# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Base::TempsTotal do
  let(:metrique_temps_total) do
    described_class.new.calcule(evenements_situation, evenements_entrainement)
  end

  describe '#temps_total' do
    context 'sans evenements' do
      let(:evenements_entrainement) { [] }
      let(:evenements_situation) { [] }

      it { expect(metrique_temps_total).to be_nil }
    end

    context 'sans entrainement' do
      let(:evenements_entrainement) { [] }
      let(:evenements_situation) do
        [
          build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
          build(:evenement_fin_situation, date: Time.zone.local(2019, 10, 9, 10, 1))
        ]
      end

      it { expect(metrique_temps_total).to eq 1.minute }
    end

    context 'situation complete' do
      let(:evenements_entrainement) do
        [
          build(:evenement_demarrage_entrainement, date: Time.zone.local(2019, 10, 9, 10, 0))
        ]
      end
      let(:evenements_situation) do
        [
          build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 1)),
          build(:evenement_fin_situation, date: Time.zone.local(2019, 10, 9, 10, 2))
        ]
      end

      it { expect(metrique_temps_total).to eq 2.minutes }
    end
  end

  describe '#format_temps_total' do
    it 'formate correctement le temps total en mm:ss pour des minutes et secondes exactes' do
      expect(described_class.format_temps_total(300)).to eq('05:00')
    end

    it 'formate correctement le temps total en mm:ss pour moins d’une minute' do
      expect(described_class.format_temps_total(45)).to eq('00:45')
    end

    it 'formate correctement le temps total en mm:ss pour zéro seconde' do
      expect(described_class.format_temps_total(0)).to eq('00:00')
    end
  end
end
