# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eva::Devise::RegistrationsController#new", type: :request do
  describe "GET /admin/sign_up avec structure_id" do
    let!(:structure) { create(:structure_locale) }

    it "redirige vers inscription_nouveau_compte_path(structure_id)" do
      expect do
        get new_compte_registration_path(structure_id: structure.id)
      end.not_to change(Invitation, :count)

      expect(response).to redirect_to(
        inscription_nouveau_compte_path(structure_id: structure.id)
      )
    end
  end

  describe "GET /admin/sign_up sans paramètre" do
    it "redirige vers inscription_nouveau_compte_path" do
      get new_compte_registration_path
      expect(response).to redirect_to(inscription_nouveau_compte_path)
    end
  end

  describe "GET /admin/sign_up avec invitation_token" do
    let!(:invitation) { create(:invitation) }

    it "redirige vers inscription_nouveau_compte_path avec le token" do
      get new_compte_registration_path(invitation_token: invitation.token)
      expect(response).to redirect_to(
        inscription_nouveau_compte_path(invitation_token: invitation.token)
      )
    end
  end
end
