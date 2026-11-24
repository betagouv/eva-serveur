require "rails_helper"

describe "Admin Structures", type: :request do
  let(:compte) { create :compte_superadmin }

  before { sign_in compte }

  {
    "structures locales" => :admin_structures_locales_path,
    "structures administratives" => :admin_structures_administratives_path,
    "structures OPCO" => :admin_structures_opcos_path
  }.each do |liste, chemin|
    it "affiche les #{liste} dans un tableau DSFR, avec les filtres de la sidebar" do
      get public_send(chemin)

      expect(response.body).to include('id="structures-component"')
      expect(response.body).to include('id="filters_sidebar_section"')
    end
  end

  it "garde les scopes du mode statistiques des structures locales" do
    get admin_structures_locales_path(stats: true)

    expect(response.body).to include('class="scopes')
    expect(response.body).to include("scope=actives")
  end
end
