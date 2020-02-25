# frozen_string_literal: true

require 'rails_helper'

class MockMetriqueTemps
  def calcule(une_liste_de_valeurs, _)
    une_liste_de_valeurs
  end
end

describe Restitution::Metriques::TempsCoherents do
  let(:metrique_temps_coherents) do
    described_class.new(MockMetriqueTemps.new, 2.7, 0.5)
  end

  describe '#temps_coherents' do
    it 'supprime une valeur trop grande' do
      expect(metrique_temps_coherents.calcule([2.7, 3.7, 3.8], [])).to eql([2.7, 3.7])
    end

    it 'supprime une valeur trop petite' do
      expect(metrique_temps_coherents.calcule([1.7, 1.8, 2.7], [])).to eql([1.8, 2.7])
    end
  end
end
