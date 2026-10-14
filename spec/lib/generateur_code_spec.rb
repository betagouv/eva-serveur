require 'rails_helper'

describe GenerateurCode do
  let(:generateur) { described_class.new(Campagne, :code) }

  describe '#genere' do
    context 'avec un suffixe fourni' do
      before do
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return('ABC')
      end

      it 'ajoute le suffixe au préfixe aléatoire' do
        expect(generateur.genere('75012')).to eq 'ABC75012'
      end
    end

    context 'sans suffixe fourni' do
      before do
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return('ABC')
        allow(GenerateurAleatoire).to receive(:nombres).with(5).and_return(12_345)
      end

      it 'ajoute un suffixe aléatoire de 5 chiffres' do
        expect(generateur.genere).to eq 'ABC12345'
      end
    end

    context 'quand le préfixe tiré est exclu' do
      before do
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return('LOL', 'GAG', 'ABC')
      end

      it 'tire un autre préfixe' do
        expect(generateur.genere('75012')).to eq 'ABC75012'
      end
    end

    context 'quand le code tiré existe déjà' do
      before do
        create :campagne, code: 'AAA75012'
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return('AAA', 'BBB')
      end

      it 'tire un autre code' do
        expect(generateur.genere('75012')).to eq 'BBB75012'
      end
    end

    context 'quand le code tiré appartient à un enregistrement supprimé' do
      before do
        create(:campagne, code: 'AAA75012').destroy
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return('AAA', 'BBB')
      end

      it 'tire un autre code' do
        expect(generateur.genere('75012')).to eq 'BBB75012'
      end
    end
  end
end
