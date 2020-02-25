# frozen_string_literal: true

require 'rails_helper'

class MockMetriqueAMoyenner < Restitution::Metriques::Base
  def calcule(une_liste_de_valeurs, _)
    une_liste_de_valeurs
  end
end

describe Restitution::Metriques::Moyenne do
  let(:metrique_moyenne) do
    described_class.new(MockMetriqueAMoyenner.new)
  end

  describe '#moyenne' do
    it "rend nil s'il n'y a pas de valeur" do
      expect(metrique_moyenne.calcule([], [])).to eql(nil)
    end

    it "calcul la moyenne d'une valeur" do
      expect(metrique_moyenne.calcule([1], [])).to eql(1.0)
    end

    it 'calcul la moyenne de deux valeurs entières' do
      expect(metrique_moyenne.calcule([1, 2], [])).to eql(1.5)
    end

    it 'arrondi à quatre chiffres après la virgule' do
      expect(metrique_moyenne.calcule([1, 1, 2], [])).to eql(1.3333)
    end
  end
end
