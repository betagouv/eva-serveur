require 'rails_helper'

describe "ActiveAdmin lower sorting initializer", type: :request do
  let(:structure_administrative) { create :structure_administrative }
  let(:compte_administratif) { create :compte_admin, structure: structure_administrative }

  before do
    sign_in compte_administratif
  end

  describe "sécurité contre les injections SQL" do
    let(:structure) do
      create :structure_locale, nom: "Test", structure_referente: structure_administrative
    end
    let(:compte) { create :compte_admin, structure: structure }
    let!(:campagne) { create :campagne, compte: compte }

    it "accepte un nom de colonne valide simple" do
      expect {
        get admin_campagnes_path, params: { order: "lower_code_asc" }
      }.not_to raise_error

      expect(response).to have_http_status(:success)
    end

    it "accepte un nom de colonne avec table qualifiée" do
      expect {
        get admin_campagnes_path, params: { order: "lower_structures.nom_asc" }
      }.not_to raise_error

      expect(response).to have_http_status(:success)
    end

    it "accepte l'ordre descendant" do
      expect {
        get admin_campagnes_path, params: { order: "lower_structures.nom_desc" }
      }.not_to raise_error

      expect(response).to have_http_status(:success)
    end

    it "rejette une injection SQL avec guillemets" do
      initial_count = Campagne.count

      expect {
        get admin_campagnes_path, params: { order: "lower_code'; DROP TABLE campagnes; --_asc" }
      }.not_to raise_error

      expect(Campagne.count).to eq(initial_count)
    end

    it "rejette une injection SQL avec parenthèses" do
      initial_count = Campagne.count

      expect {
        get admin_campagnes_path, params: { order: "lower_code); DROP TABLE campagnes; --_asc" }
      }.not_to raise_error

      expect(Campagne.count).to eq(initial_count)
    end

    it "rejette des caractères spéciaux dangereux (chevrons)" do
      initial_count = Campagne.count

      expect {
        get admin_campagnes_path, params: { order: "lower_code<script>_asc" }
      }.not_to raise_error

      expect(Campagne.count).to eq(initial_count)
    end

    it "rejette une colonne avec espaces (tentative OR injection)" do
      initial_count = Campagne.count

      expect {
        get admin_campagnes_path, params: { order: "lower_code OR 1=1_asc" }
      }.not_to raise_error

      expect(Campagne.count).to eq(initial_count)
    end

    it "rejette une tentative d'injection via UNION" do
      initial_count = Campagne.count

      expect {
        get admin_campagnes_path,
          params: { order: "lower_code UNION SELECT password FROM users--_asc" }
      }.not_to raise_error

      expect(Campagne.count).to eq(initial_count)
    end
  end

  describe "fonctionnement normal du tri insensible à la casse" do
    let(:structure_a) do
      create :structure_locale, nom: "aaa Structure", structure_referente: structure_administrative
    end
    let(:structure_b) do
      create :structure_locale, nom: "BBB Structure", structure_referente: structure_administrative
    end
    let(:compte_a) { create :compte_admin, structure: structure_a }
    let(:compte_b) { create :compte_admin, structure: structure_b }
    let!(:campagne_a) { create :campagne, libelle: "Campagne A", compte: compte_a }
    let!(:campagne_b) { create :campagne, libelle: "Campagne B", compte: compte_b }

    it "trie correctement avec lower_ prefix" do
      get admin_campagnes_path, params: { order: "lower_structures.nom_asc" }

      expect(response).to have_http_status(:success)
      position_a = response.body.index(campagne_a.libelle)
      position_b = response.body.index(campagne_b.libelle)
      expect(position_a).to be < position_b
    end
  end

  describe "validation de la regex" do
    it "valide le format de colonne correctement" do
      valid_patterns = [
        "lower_code_asc",
        "lower_structures.nom_asc",
        "lower_table_name.column_name_desc",
        "lower_col123_asc"
      ]

      expect(valid_patterns).to all(match(ActiveAdminLowerSorting::ORDER_PARAM_REGEX))
    end

    it "rejette les formats invalides" do
      invalid_patterns = [
        "lower_code'; DROP--_asc",  # Contient guillemet et tirets
        "lower_code OR 1=1_asc",    # Contient espaces
        "lower_code<script>_asc",   # Contient chevrons
        "lower_code)--_asc",        # Contient parenthèse et tirets
        "lower_code UNION_asc",      # Contient espace
        "code_asc"      # n'est pas une demande de tri sans tenir compte de la casse
      ]

      invalid_patterns.each do |pattern|
        expect(pattern).not_to match(ActiveAdminLowerSorting::ORDER_PARAM_REGEX)
      end
    end
  end
end
