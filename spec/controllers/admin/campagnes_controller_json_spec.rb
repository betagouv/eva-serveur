require 'rails_helper'

describe Admin::CampagnesController, type: :controller do
  render_views

  describe "export JSON" do
    let(:structure) { create :structure_locale }
    let!(:compte) { create :compte_admin, structure: structure }
    let!(:campagne) do
      create :campagne,
             compte: compte,
             libelle: "Ma Campagne",
             code: "CAMP01"
    end

    before do
      sign_in compte
    end

    it "retourne les campagnes au format JSON avec uniquement les champs autorisés" do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include("application/json")

      resultat = response.parsed_body
      campagne_json = resultat.find { |c| c["id"] == campagne.id }

      expect(campagne_json.keys).to match_array(%w[id libelle code display_name])
      expect(campagne_json["libelle"]).to eq("Ma Campagne")
      expect(campagne_json["code"]).to eq("CAMP01")
    end
  end
end
