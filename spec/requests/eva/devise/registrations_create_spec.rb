# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /admin (ancienne inscription Devise)", type: :request do
  it "n'existe plus et ne crée pas de compte" do
    parametres = { compte: { email: "nouveau@exemple.fr", password: "Password78901$",
                             password_confirmation: "Password78901$" } }

    expect do
      post "/admin", params: parametres
    end.not_to change(Compte, :count)

    expect(response).to have_http_status(:not_found)
  end
end
