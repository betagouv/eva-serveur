require "rails_helper"

describe "Ransack initializer", type: :model do
  describe "contains_unaccent predicate" do
    let!(:beneficiaire_avec_accents) { create(:beneficiaire, nom: "José García") }
    let!(:beneficiaire_sans_accents) { create(:beneficiaire, nom: "Pierre Dupont") }
    let!(:beneficiaire_eleve) { create(:beneficiaire, nom: "Élève Martin") }

    it "trouve les résultats sans tenir compte des accents" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Jose").result
      expect(resultats).to include(beneficiaire_avec_accents)
    end

    it "trouve les résultats sans tenir compte de la casse" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "jose").result
      expect(resultats).to include(beneficiaire_avec_accents)
    end

    it "trouve les résultats avec recherche partielle" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Garc").result
      expect(resultats).to include(beneficiaire_avec_accents)
    end

    it "trouve les résultats en cherchant sans accents alors que la donnée a des accents" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "eleve").result
      expect(resultats).to include(beneficiaire_eleve)
    end

    it "trouve les résultats en cherchant avec accents alors que la donnée n'en a pas" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Piérre").result
      expect(resultats).to include(beneficiaire_sans_accents)
    end

    it "ne trouve pas de résultats quand aucun ne correspond" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Inexistant").result
      expect(resultats).to be_empty
    end
  end
end
