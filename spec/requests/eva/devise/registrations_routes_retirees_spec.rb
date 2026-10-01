require "rails_helper"

RSpec.describe "Routes Devise d'inscription et de gestion de son propre compte", type: :request do
  context "sans être connecté" do
    it "n'affiche plus l'ancienne page d'inscription" do
      get "/admin/sign_up"
      expect(response).to have_http_status(:not_found)

      get "/admin/sign_up", params: { invitation_token: create(:invitation).token }
      expect(response).to have_http_status(:not_found)
    end

    it "ne permet plus de créer un compte" do
      parametres = { compte: { email: "nouveau@exemple.fr", password: "Password78901$",
                               password_confirmation: "Password78901$" } }

      expect do
        post "/admin", params: parametres
      end.not_to change(Compte, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  context "en étant connecté" do
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
  end
end
