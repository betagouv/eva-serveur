# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eva::Devise::PasswordsController#create", type: :request do
  describe "POST /admin/password" do
    context "avec un email inconnu" do
      it "réaffiche le formulaire avec l'erreur d'email introuvable" do
        post compte_password_path, params: { compte: { email: "inconnu@example.com" } }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("n’a pas été trouvé(e)")
        expect(response.body).not_to include("<ul class=\"errors\">")
      end
    end

    context "avec un email d'un compte existant" do
      let!(:compte) { create(:compte) }

      it "envoie les instructions de réinitialisation" do
        expect do
          post compte_password_path, params: { compte: { email: compte.email } }
        end.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(response).to redirect_to(new_compte_session_path)
      end
    end
  end
end
