# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:restitution_globale) { Restitution::Globale.new restitutions: restitutions }

  describe '#utilisateur retoure le nom de sa première restitution' do
    let(:restitutions) { [double(utilisateur: 'Jean Bon')] }
    it { expect(restitution_globale.utilisateur).to eq('Jean Bon') }
  end

  describe '#date retourne la date de sa première restitution' do
    let(:date) { 2.days.ago }
    let(:restitutions) { [double(date: date)] }
    it { expect(restitution_globale.date).to eq(date) }
  end

  describe '#efficience est la moyenne des efficiences' do
    context "sans restitution c'est incalculable" do
      let(:restitutions) { [] }
      it { expect(restitution_globale.efficience).to eq(0) }
    end

    context 'une restitution: son efficience' do
      let(:restitutions) { [double(efficience: 15)] }
      it { expect(restitution_globale.efficience).to eq(15) }
    end

    context 'plusieurs restitutions : la moyenne' do
      let(:restitutions) { [double(efficience: 15), double(efficience: 20)] }
      it { expect(restitution_globale.efficience).to eq(17.5) }
    end

    context 'retourne une efficience indéterminée si une restitution est indéterminé' do
      let(:restitutions) do
        [double(efficience: 20), double(efficience: ::Restitution::Globale::NIVEAU_INDETERMINE)]
      end
      it {
        expect(restitution_globale.efficience).to eq(::Restitution::Globale::NIVEAU_INDETERMINE)
      }
    end
  end
end
