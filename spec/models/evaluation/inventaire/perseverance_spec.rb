# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::Perseverance do
  let(:evaluation) { double }

  it 'en réussite et en plus de 22 min: niveau 4' do
    expect(evaluation).to receive(:reussite?).and_return(true)
    expect(evaluation).to receive(:temps_total).and_return(23.minutes.to_i)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'abandon après 1 essai avec erreurs: niveau 1' do
    essai = double
    expect(essai).to receive(:nombre_erreurs).and_return(5)
    expect(evaluation).to receive(:reussite?).and_return(false)
    expect(evaluation).to receive(:abandon?).and_return(true)
    expect(evaluation).to receive(:nombre_essais_validation).and_return(1)
    expect(evaluation).to receive(:essais).and_return([essai])
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'abandon après essais avec de bonnes réponses puis abandon en moins de 22min: niveau 1' do
    essai = double
    expect(essai).to receive(:nombre_erreurs).and_return(5)
    expect(evaluation).to receive(:reussite?).and_return(false)
    expect(evaluation).to receive(:abandon?).and_return(true)
    expect(evaluation).to receive(:temps_total).and_return(21.minutes.to_i)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(2)
    expect(evaluation).to receive(:essais).and_return([essai])
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'dans les autres cas, niveau indéterminé' do
    expect(evaluation).to receive(:reussite?).and_return(true)
    expect(evaluation).to receive(:temps_total).and_return(15.minutes.to_i)
    expect(evaluation).to receive(:abandon?).and_return(false)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(0)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
