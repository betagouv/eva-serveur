require "rails_helper"

describe "Admin Campagnes", type: :request do
  let(:compte) { create :compte_superadmin }
  let!(:paris) { create :campagne, libelle: "Paris 2025", compte: compte }
  let!(:lyon) { create :campagne, libelle: "Lyon 2025", compte: compte }

  before { sign_in compte }

  describe "GET index" do
    it "affiche la liste dans le cadre de l'administration, sans sa barre de titre" do
      get admin_campagnes_path

      expect(response.body).to include("<title>Campagnes | eva</title>")
      expect(response.body).to include("fr-header")
      expect(response.body).not_to include('id="title_bar"')
    end

    it "pagine la liste avec la pagination DSFR" do
      get admin_campagnes_path(per_page: 1)

      expect(response.body).to include("fr-pagination__list")
    end

    it "sert toujours la recherche JSON utilisée par les autres filtres" do
      Bullet.enable = false
      get admin_campagnes_path(format: :json, q: { libelle_or_code_i_cont: "paris" })

      expect(response.parsed_body.pluck("id")).to contain_exactly(paris.id)
    ensure
      Bullet.enable = true
    end
  end
end
