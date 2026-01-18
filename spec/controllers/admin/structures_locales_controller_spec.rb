require 'rails_helper'

describe Admin::StructuresLocalesController, type: :controller do
  render_views

  describe "export JSON" do
    let!(:compte_superadmin) { create :compte_superadmin }
    let!(:structure_locale) do
      create :structure_locale,
             nom: "Structure Locale Test",
             code_postal: "69001"
    end

    before do
      sign_in compte_superadmin
    end

    it "retourne les structures locales au format JSON avec uniquement les champs autorisés" do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include("application/json")

      resultat = response.parsed_body
      structure_json = resultat.find { |s| s["id"] == structure_locale.id }

      expect(structure_json.keys).to match_array(%w[id nom code_postal display_name])
      expect(structure_json["nom"]).to eq("Structure Locale Test")
      expect(structure_json["code_postal"]).to eq("69001")
    end
  end
end
