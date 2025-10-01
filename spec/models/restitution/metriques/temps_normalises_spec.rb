require 'rails_helper'

describe Restitution::Metriques::TempsNormalises do
  describe '#temps_coherents' do
    let(:mock_metrique_temps) { double }
    let(:metrique_temps_coherents) do
      described_class.new(mock_metrique_temps, 2.7, 0.5)
    end

    it 'supprime une valeur trop grande' do
      expect(mock_metrique_temps).to receive(:calcule).and_return([ 2.7, 3.7, 3.8 ])
      expect(metrique_temps_coherents.calcule([], [])).to eql([ 2.7, 3.7 ])
    end

    it 'supprime une valeur trop petite' do
      expect(mock_metrique_temps).to receive(:calcule).and_return([ 1.7, 1.8, 2.7 ])
      expect(metrique_temps_coherents.calcule([], [])).to eql([ 1.8, 2.7 ])
    end
  end
end
