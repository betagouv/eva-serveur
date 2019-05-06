# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Controle::ComprehensionConsigne do
  let(:evaluation) { double }

  it 'a terminé en moins de 15 erreurs ou de ratées: niveau 4' do
    allow(evaluation).to receive(:termine?).and_return(true)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(36)
    allow(evaluation).to receive(:nombre_loupees).and_return(14)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'a terminé en plus de 15 loupés: niveau 1' do
    allow(evaluation).to receive(:termine?).and_return(true)
    allow(evaluation).to receive(:nombre_loupees).and_return(16)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(44)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'a réécouté la consigne, a fait des erreurs en triant 10 biscuits et abandon: niveau 1' do
    allow(evaluation).to receive(:termine?).and_return(false)
    allow(evaluation).to receive(:abandon?).and_return(true)
    allow(evaluation).to receive(:nombre_rejoue_consigne).and_return(1)
    allow(evaluation).to receive(:nombre_loupees).and_return(8)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(1)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it "a réécouté la consigne, pas d'erreur et abandon : indéterminé" do
    allow(evaluation).to receive(:termine?).and_return(false)
    allow(evaluation).to receive(:abandon?).and_return(true)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(9)
    allow(evaluation).to receive(:nombre_rejoue_consigne).and_return(1)
    allow(evaluation).to receive(:nombre_loupees).and_return(0)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end

  it 'en abandonnant après > 10 biscuits: niveau indeterminé' do
    allow(evaluation).to receive(:termine?).and_return(false)
    allow(evaluation).to receive(:abandon?).and_return(true)
    allow(evaluation).to receive(:nombre_loupees).and_return(22)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(1)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
