require 'rails_helper'

describe EvenementEvacob do
  describe '#module?' do
    def evenement(id_question)
      described_class.new Evenement.new nom: 'reponse', donnees: {
        question: id_question
      }
    end

    it "retourne vrai s'il est du module demandé" do
      expect(evenement('LOdi1').module?(:orientation)).to be true
      expect(evenement('HPar1').module?(:hpar)).to be true
      expect(evenement('HGac1').module?(:hgac)).to be true
      expect(evenement('HCvf1').module?(:hcvf)).to be true
      expect(evenement('HPfb1').module?(:hpfb)).to be true
      expect(evenement('ALrd1').module?(:orientation)).to be false
    end
  end

  describe '#metacompetence?' do
    def evenement(metacompetence)
      described_class.new Evenement.new nom: 'reponse', donnees: {
        metacompetence: metacompetence
      }
    end

    it "retourne vrai si c'est la metacompetence demandée" do
      expect(evenement('lecture').metacompetence?('lecture')).to be true
      expect(evenement('comprehension').metacompetence?('lecture')).to be false
    end
  end
end
