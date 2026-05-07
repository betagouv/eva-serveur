require "rails_helper"

describe FormatageSiretHelper do
  describe ".formater_siret" do
    it "formate un siret brut en 3-3-3-5" do
      expect(described_class.formater_siret("12345678901234")).to eq("123 456 789 01234")
    end

    it "supprime les caractères non numériques avant formatage" do
      expect(described_class.formater_siret("123 456-789.01234")).to eq("123 456 789 01234")
    end

    it "tronque à 14 chiffres" do
      expect(described_class.formater_siret("123456789012345678")).to eq("123 456 789 01234")
    end

    it "retourne nil pour une valeur vide" do
      expect(described_class.formater_siret(nil)).to be_nil
      expect(described_class.formater_siret("")).to be_nil
      expect(described_class.formater_siret("abc")).to be_nil
    end

    context "avec un siret partiel" do
      it "ne lève pas d'exception et formate les groupes disponibles" do
        aggregate_failures do
          expect { described_class.formater_siret("1") }.not_to raise_error
          expect(described_class.formater_siret("1")).to eq("1")
          expect(described_class.formater_siret("1234")).to eq("123 4")
          expect(described_class.formater_siret("123456789")).to eq("123 456 789")
        end
      end
    end
  end
end
