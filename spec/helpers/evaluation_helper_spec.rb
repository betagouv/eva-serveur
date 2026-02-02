require 'rails_helper'

describe EvaluationHelper do
  describe '#niveau_bas?' do
    let(:profil1) { Competence::PROFILS_BAS.first }
    let(:profil_autre) { :profil_autre }

    it 'Retourne true si le profil renseigné est un niveau bas' do
      expect(niveau_bas?(:profil1)).to be true
    end

    it "Retourne false si le profil renseigné n'est pas un niveau bas" do
      expect(niveau_bas?(:profil_autre)).to be false
    end
  end

  describe '#palier_pourcentage_risque' do
    context 'quand le pourcentage est entre 0 et 10' do
      it 'retourne "A - Très bon" pour 0' do
        expect(palier_pourcentage_risque(0)).to eq("A - Très bon")
      end

      it 'retourne "A - Très bon" pour 10' do
        expect(palier_pourcentage_risque(10)).to eq("A - Très bon")
      end
    end

    context 'quand le pourcentage est entre 11 et 25' do
      it 'retourne "B - Bon" pour 11' do
        expect(palier_pourcentage_risque(11)).to eq("B - Bon")
      end

      it 'retourne "B - Bon" pour 25' do
        expect(palier_pourcentage_risque(25)).to eq("B - Bon")
      end
    end

    context 'quand le pourcentage est entre 26 et 50' do
      it 'retourne "C - Moyen" pour 26' do
        expect(palier_pourcentage_risque(26)).to eq("C - Moyen")
      end

      it 'retourne "C - Moyen" pour 50' do
        expect(palier_pourcentage_risque(50)).to eq("C - Moyen")
      end
    end

    context 'quand le pourcentage est entre 51 et 100' do
      it 'retourne "D - Mauvais" pour 51' do
        expect(palier_pourcentage_risque(51)).to eq("D - Mauvais")
      end

      it 'retourne "D - Mauvais" pour 100' do
        expect(palier_pourcentage_risque(100)).to eq("D - Mauvais")
      end
    end

    context 'quand le pourcentage est hors limites' do
      it 'retourne "D - Mauvais" pour une valeur supérieure à 100' do
        expect(palier_pourcentage_risque(150)).to eq("D - Mauvais")
      end
    end
  end
end
