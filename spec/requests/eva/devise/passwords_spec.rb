# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eva::Devise::PasswordsController#update", type: :request do
  describe "PUT /admin/password" do
    context "avec un token valide et des mots de passe non conformes" do
      let!(:compte) { create(:compte) }

      it "réaffiche le formulaire sans erreur NoMethodError sur @reset_password" do
        raw_token, _hashed = Devise.token_generator.generate(Compte, :reset_password_token)
        compte.update!(
          reset_password_token: Devise.token_generator.digest(Compte, :reset_password_token, raw_token),
          reset_password_sent_at: Time.current
        )

        put compte_password_path, params: {
          compte: {
            reset_password_token: raw_token,
            password: "court",
            password_confirmation: "court"
          }
        }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end

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
