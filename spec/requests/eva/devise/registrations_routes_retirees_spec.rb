# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Routes Devise de gestion de son propre compte", type: :request do
  let(:compte) { create(:compte_admin) }

  before { sign_in compte }

  it "ne permet plus de supprimer son compte" do
    delete "/admin"

    expect(response).to have_http_status(:not_found)
    expect(Compte.exists?(compte.id)).to be true
  end

  it "ne permet plus de modifier son compte" do
    parametres = { compte: { email: "nouveau@exemple.fr", current_password: compte.password } }

    patch "/admin", params: parametres
    expect(response).to have_http_status(:not_found)

    put "/admin", params: parametres
    expect(response).to have_http_status(:not_found)
  end

  it "n'affiche plus les pages Devise de modification et d'annulation" do
    get "/admin/edit"
    expect(response).to have_http_status(:not_found)

    get "/admin/cancel"
    expect(response).to have_http_status(:not_found)
  end

  it "conserve les routes qui redirigent l'ancienne inscription" do
    expect(new_compte_registration_path).to eq "/admin/sign_up"
    expect(compte_registration_path).to eq "/admin"
  end
end
