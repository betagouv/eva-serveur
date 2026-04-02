# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Invitation invalide ou déjà utilisée", type: :request do
  it "redirige vers la recherche de structure avec un message d'erreur" do
    get inscription_nouveau_compte_path(invitation_token: "token-inconnu")

    expect(response).to redirect_to(structures_path)
    follow_redirect!
    expect(flash[:alert]).to eq(I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee"))
  end

  it "redirige vers la recherche de structure si l'invitation est annulée" do
    invitation = create(:invitation, :annulee)

    get inscription_nouveau_compte_path(invitation_token: invitation.token)

    expect(response).to redirect_to(structures_path)
    follow_redirect!
    expect(flash[:alert]).to eq(I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee"))
  end

  it "redirige vers la recherche de structure si l'invitation a déjà été acceptée" do
    invitation = create(:invitation, :acceptee)

    get inscription_nouveau_compte_path(invitation_token: invitation.token)

    expect(response).to redirect_to(structures_path)
    follow_redirect!
    expect(flash[:alert]).to eq(I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee"))
  end
end
