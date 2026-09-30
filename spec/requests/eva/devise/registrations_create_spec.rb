# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eva::Devise::RegistrationsController#create", type: :request do
  let!(:structure) { create(:structure_locale, :avec_admin) }
  let(:compte) do
    { email: "nouveau@exemple.fr", password: "Password78901$",
      password_confirmation: "Password78901$", prenom: "Nouveau", nom: "Compte",
      structure_id: structure.id, cgu_acceptees: true }
  end

  it "redirige vers inscription_nouveau_compte_path sans créer de compte" do
    expect do
      post compte_registration_path, params: { compte: compte }
    end.not_to change(Compte, :count)

    expect(response).to redirect_to(inscription_nouveau_compte_path)
    expect(response).to have_http_status(:see_other)
  end

  it "conserve le token d'invitation dans la redirection" do
    invitation = create(:invitation)

    expect do
      post compte_registration_path,
           params: { invitation_token: invitation.token, compte: compte }
    end.not_to change(Compte, :count)

    expect(response).to redirect_to(
      inscription_nouveau_compte_path(invitation_token: invitation.token)
    )
  end
end
