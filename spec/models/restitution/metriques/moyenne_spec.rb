# frozen_string_literal: true

require 'rails_helper'

class MetriqueAMoyenner < Restitution::Metriques::Base
  def calcule
    @evenements_situation
  end
end

class MoyenneMetrique < Restitution::Metriques::Moyenne
  def classe_metrique
    MetriqueAMoyenner
  end
end

describe Restitution::Metriques::Moyenne do
  describe '#moyenne' do
    it "rend nil s'il n'y a pas de valeur" do
      expect(MoyenneMetrique.new([], []).calcule).to eql(nil)
    end

    it "calcul la moyenne d'une valeur" do
      expect(MoyenneMetrique.new([1], []).calcule).to eql(1.0)
    end

    it 'calcul la moyenne de deux valeurs entières' do
      expect(MoyenneMetrique.new([1, 2], []).calcule).to eql(1.5)
    end

    it 'arrondi à quatre chiffres après la virgule' do
      expect(MoyenneMetrique.new([1, 1, 2], []).calcule).to eql(1.3333)
    end
  end
end
