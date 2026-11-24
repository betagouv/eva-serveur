require "rails_helper"

describe "Admin Comptes", type: :request do
  let(:compte) { create :compte_superadmin }

  before { sign_in compte }

  describe "GET index" do
    it "affiche le tableau dans le cadre de l'administration, avec ses filtres" do
      get admin_comptes_path

      expect(response.body).to include("<title>Comptes | eva</title>")
      expect(response.body).to include('id="filters_sidebar_section"')
      expect(response.body).to include('id="comptes-component"')
    end

    it "garde les scopes du mode statistiques, avec leurs compteurs" do
      get admin_comptes_path(stats: true)

      expect(response.body).to include('class="scopes')
      expect(response.body).to include("scope=actives")
    end
  end
end
