# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Globale do
  let(:evaluation_globale) { Evaluation::Globale.new evaluations: evaluations }

  describe '#utilisateur retoure le nom de sa première évaluation' do
    let(:evaluations) { [double(utilisateur: 'Jean Bon')] }
    it { expect(evaluation_globale.utilisateur).to eq('Jean Bon') }
  end

  describe '#date retourne la date de sa première évaluation' do
    let(:date) { 2.days.ago }
    let(:evaluations) { [double(date: date)] }
    it { expect(evaluation_globale.date).to eq(date) }
  end

  describe '#efficience est la moyenne des efficiences' do
    context "sans evaluation c'est incalculable" do
      let(:evaluations) { [] }
      it { expect(evaluation_globale.efficience).to eq(nil) }
    end

    context 'une evaluation: son efficience' do
      let(:evaluations) { [double(efficience: 15)] }
      it { expect(evaluation_globale.efficience).to eq(15) }
    end

    context 'plusieurs évaluations : la moyenne' do
      let(:evaluations) { [double(efficience: 15), double(efficience: 20)] }
      it { expect(evaluation_globale.efficience).to eq(17.5) }
    end

    context 'ignore les évaluations vides' do
      let(:evaluations) { [double(efficience: 20), double(efficience: nil)] }
      it { expect(evaluation_globale.efficience).to eq(20) }
    end
  end
end
