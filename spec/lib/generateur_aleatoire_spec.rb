# frozen_string_literal: true

require 'rails_helper'

describe GenerateurAleatoire do
  describe '#majuscules' do
    it 'permet de choisir la longueur' do
      chaine_generee = described_class.majuscules 15
      expect(chaine_generee.size).to eq 15
    end

    it 'génère des résultats différents à chaque appel' do
      generation1 = described_class.majuscules 10
      generation2 = described_class.majuscules 10
      expect(generation1).not_to eq generation2
    end

    it 'contient uniquement des lettres majuscules' do
      chaine_generee = described_class.majuscules 20
      expect(chaine_generee.upcase).to eq chaine_generee
    end

    it 'ne contient pas de lettre en double' do
      chaine_generee = described_class.majuscules 26
      expect(chaine_generee.chars.uniq.size).to eq 26
    end
  end

  describe '#nombres' do
    it 'permet de choisir la longueur' do
      chaine_generee = described_class.nombres 15
      expect(chaine_generee.to_s.size).to eq 15
    end

    it 'génère des résultats différents à chaque appel' do
      generation1 = described_class.nombres 10
      generation2 = described_class.nombres 10
      expect(generation1).not_to eq generation2
    end
  end
end
