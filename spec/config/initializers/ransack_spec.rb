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

    it "trouve les résultats en cherchant sans accents quand la donnée en a" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "eleve").result
      expect(resultats).to include(beneficiaire_eleve)
    end

    it "trouve les résultats en cherchant avec accents quand la donnée n'en a pas" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Piérre").result
      expect(resultats).to include(beneficiaire_sans_accents)
    end

    it "ne trouve pas de résultats quand aucun ne correspond" do
      resultats = Beneficiaire.ransack(nom_contains_unaccent: "Inexistant").result
      expect(resultats).to be_empty
    end

    context "recherche avec le paramètre cont transformé en contains_unaccent" do
      it "trouve les bénéficiaires en utilisant nom_cont sans tenir compte des accents" do
        # Simule le comportement du search_select_filter qui utilise _cont
        resultats = Beneficiaire.ransack(nom_cont: "Jose").result
        expect(resultats).to include(beneficiaire_avec_accents)
      end

      it "recherche exacte sur code_beneficiaire (pas de transformation unaccent)" do
        code_partiel = beneficiaire_avec_accents.code_beneficiaire[0..2]
        resultats = Beneficiaire.ransack(code_beneficiaire_cont: code_partiel).result
        expect(resultats).to include(beneficiaire_avec_accents)

        # Vérifie que la recherche reste sensible à la casse pour le code
        expect(resultats.to_sql).not_to include("unaccent")
        expect(resultats.to_sql).to include("code_beneficiaire")
      end

      it "trouve les bénéficiaires avec des paramètres imbriqués (groupings)" do
        # Simule exactement le format utilisé par search_select_filter
        params = {
          groupings: [
            {
              m: "or",
              nom_cont: "Jose",
              code_beneficiaire_cont: "Jose"
            }
          ],
          combinator: "and"
        }
        resultats = Beneficiaire.ransack(params).result
        expect(resultats).to include(beneficiaire_avec_accents)
      end

      it "trouve les bénéficiaires quand on cherche sans accent quand les données en ont" do
        create(:beneficiaire, nom: "Étienne Dupont")
        params = {
          groupings: [
            {
              m: "or",
              nom_cont: "etienne",
              code_beneficiaire_cont: "etienne"
            }
          ],
          combinator: "and"
        }
        resultats = Beneficiaire.ransack(params).result
        expect(resultats.map(&:nom)).to include("Étienne Dupont")
      end
    end
  end
end
