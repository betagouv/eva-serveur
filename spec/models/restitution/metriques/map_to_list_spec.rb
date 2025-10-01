require 'rails_helper'

describe Restitution::Metriques::MapToList do
  let(:mock_metrique_a_moyenner) { double }
  let(:metrique_moyenne) do
    described_class.new(mock_metrique_a_moyenner)
  end

  describe '#moyenne' do
    it "quand il n'y a pas de valeur" do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return({})
      expect(metrique_moyenne.calcule([], [])).to eql([])
    end

    it 'rend une liste des valeurs quand il y en a' do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return({ mesure: 1, mesure2: 1.1 })
      expect(metrique_moyenne.calcule([], [])).to eql([ 1, 1.1 ])
    end
  end
end
