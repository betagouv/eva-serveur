require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau1 do
  let(:interpreteur_score) { double }
  let(:subject) do
    described_class.new interpreteur_score
  end

  describe '#interpretations_cefr' do
    let(:interpretations_cefr) do
      [
        { litteratie: :palier1 }, { numeratie: :palier1 }
      ]
    end

    before do
      allow(interpreteur_score).to receive(:interpretations)
        .with(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1, :CEFR)
        .and_return(interpretations_cefr)
    end

    it { expect(subject.interpretations_cefr).to eq({ litteratie: :A1, numeratie: :X1 }) }
  end

  describe '#interpretations_anlci' do
    let(:interpretations_anlci) do
      [
        { litteratie: :palier1 }, { numeratie: :palier2 }
      ]
    end

    before do
      allow(interpreteur_score).to receive(:interpretations)
        .with(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1, :ANLCI)
        .and_return(interpretations_anlci)
    end

    it do
      expect(subject.interpretations_anlci).to eq({ litteratie: :profil2, numeratie: :profil3 })
    end
  end
end
