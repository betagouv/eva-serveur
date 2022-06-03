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

    it "retourn vrai s'il est du module lecture_complet" do
      expect(evenement('ALrd1').module?(:lecture_complet)).to be true
      expect(evenement('ALrd14').module?(:lecture_complet)).to be true
      expect(evenement('LOdi2').module?(:lecture_complet)).to be true
      expect(evenement('LOdi4').module?(:lecture_complet)).to be true
      expect(evenement('LOdi5').module?(:lecture_complet)).to be true
      expect(evenement('LOdi1').module?(:lecture_complet)).to be false
      expect(evenement('LOdi3').module?(:lecture_complet)).to be false
    end
  end
end
