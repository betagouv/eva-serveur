require 'rails_helper'

describe Admin::StructuresController, type: :controller do
  render_views

  describe "export JSON" do
    let!(:compte_superadmin) { create :compte_superadmin }
    let!(:structure) do
      create :structure_locale,
             nom: "Ma Structure",
             code_postal: "75001"
    end

    before do
      sign_in compte_superadmin
    end

    it "retourne les structures au format JSON avec uniquement les champs autorisés" do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include("application/json")

      resultat = response.parsed_body
      structure_json = resultat.find { |s| s["id"] == structure.id }

      expect(structure_json.keys).to match_array(%w[id nom code_postal display_name])
      expect(structure_json["nom"]).to eq("Ma Structure")
      expect(structure_json["code_postal"]).to eq("75001")
    end
  end
end
