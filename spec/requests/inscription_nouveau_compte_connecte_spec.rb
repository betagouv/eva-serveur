# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inscription - Nouveau compte, en étant déjà connecté", type: :request do
  it "redirige vers le tableau de bord un compte à l'étape « nouveau »" do
    compte = create(:compte, etape_inscription: "nouveau")
    sign_in compte

    get inscription_nouveau_compte_path

    expect(response).to redirect_to(admin_dashboard_path)
  end
end
