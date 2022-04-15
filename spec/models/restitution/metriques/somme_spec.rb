# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Metriques::Somme do
  let(:mock_metriques_a_additionner) { double }
  let(:metrique_somme) do
    described_class.new(mock_metriques_a_additionner)
  end

  describe '#somme' do
    it "rend nil s'il n'y a pas de valeur" do
      expect(mock_metriques_a_additionner).to receive(:calcule).and_return([])
      expect(metrique_somme.calcule([], [])).to be_nil
    end

    it "calcul la somme d'une valeur" do
      expect(mock_metriques_a_additionner).to receive(:calcule).and_return([1])
      expect(metrique_somme.calcule([], [])).to be(1)
    end

    it 'calcul la moyenne de deux valeurs entières' do
      expect(mock_metriques_a_additionner).to receive(:calcule).and_return([1, 2])
      expect(metrique_somme.calcule([], [])).to be(3)
    end
  end
end
