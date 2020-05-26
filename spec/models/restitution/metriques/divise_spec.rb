# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Metriques::Divise do
  let(:mock_metrique_numerateur) { double }
  let(:mock_metrique_denominateur) { double }

  let(:metrique_moyenne) do
    described_class.new(mock_metrique_numerateur, mock_metrique_denominateur)
  end

  describe '#divise' do
    it "rend nil s'il n'y a pas de valeur pour le numerateur" do
      expect(mock_metrique_numerateur).to receive(:calcule).and_return(nil)
      expect(metrique_moyenne.calcule([], [])).to eql(nil)
    end

    it "rend nil s'il n'y a pas de valeur pour le denominateur" do
      expect(mock_metrique_numerateur).to receive(:calcule).and_return(0)
      expect(mock_metrique_denominateur).to receive(:calcule).and_return(nil)
      expect(metrique_moyenne.calcule([], [])).to eql(nil)
    end

    it "rend nil s'il n'y une valeur zero pour le denominateur" do
      expect(mock_metrique_numerateur).to receive(:calcule).and_return(1)
      expect(mock_metrique_denominateur).to receive(:calcule).and_return(0)
      expect(metrique_moyenne.calcule([], [])).to eql(nil)
    end

    it 'rend la division' do
      expect(mock_metrique_numerateur).to receive(:calcule).and_return(1)
      expect(mock_metrique_denominateur).to receive(:calcule).and_return(2)
      expect(metrique_moyenne.calcule([], [])).to eql(0.5)
    end
  end
end
