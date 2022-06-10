# frozen_string_literal: true

require 'rails_helper'

describe EvenementEvacob do
  describe '#module?' do
    def evenement(id_question)
      described_class.new Evenement.new nom: 'reponse', donnees: {
        question: id_question
      }
    end

    it "retourn vrai s'il est du module orientation" do
      expect(evenement('LOdi1').module?(:orientation)).to be true
      expect(evenement('ALrd1').module?(:orientation)).to be false
    end
  end

  describe '#metacompetence?' do
    def evenement(metacompetence)
      described_class.new Evenement.new nom: 'reponse', donnees: {
        metacompetence: metacompetence
      }
    end

    it "retourn vrai si c'est la metacompetence demandée" do
      expect(evenement('lecture').metacompetence?('lecture')).to be true
      expect(evenement('comprehension').metacompetence?('lecture')).to be false
    end
  end
end
