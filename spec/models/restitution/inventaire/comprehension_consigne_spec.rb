# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Inventaire::ComprehensionConsigne do
  let(:restitution) { double }

  it 'en réussite: niveau 4' do
    expect(restitution).to receive(:reussite?).and_return(true)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'abandon après un essai avec 8 erreurs: niveau 1' do
    essai = double
    expect(essai).to receive(:nombre_erreurs).and_return(8)
    expect(restitution).to receive(:nombre_essais_validation).and_return(1)
    expect(restitution).to receive(:reussite?).and_return(false)
    expect(restitution).to receive(:abandon?).and_return(true)
    expect(restitution).to receive(:essais_verifies).and_return([ essai ])
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'abandon après 2 réécoute de la consigne: niveau 1' do
    expect(restitution).to receive(:nombre_essais_validation).and_return(2)
    expect(restitution).to receive(:reussite?).and_return(false)
    expect(restitution).to receive(:abandon?).and_return(true)
    expect(restitution).to receive(:nombre_rejoue_consigne).and_return(2)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'abandon simple: niveau indéfini' do
    expect(restitution).to receive(:nombre_essais_validation).and_return(2)
    expect(restitution).to receive(:reussite?).and_return(false)
    expect(restitution).to receive(:abandon?).and_return(true)
    expect(restitution).to receive(:nombre_rejoue_consigne).and_return(0)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
