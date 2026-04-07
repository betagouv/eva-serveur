# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Invitation invalide ou déjà utilisée", type: :request do
  it "redirige vers la page dédiée si le token est inconnu" do
    get inscription_nouveau_compte_path(invitation_token: "token-inconnu")

    expect(response).to redirect_to(inscription_invitation_invalide_path)
    follow_redirect!
    expect(response.body).to include("Ce lien d’invitation n’est pas valide ou a déjà été utilisé")
    expect(response.body).to include(
      "Vous avez sûrement déjà créé un compte avec ce lien d’invitation. Si ce n’est pas le cas, "\
      "contactez un référent de votre structure."
    )
    expect(response.body).to include("Aller à l’accueil pour se connecter")
  end

  it "redirige vers la page dédiée si l'invitation est annulée" do
    invitation = create(:invitation, :annulee)

    get inscription_nouveau_compte_path(invitation_token: invitation.token)

    expect(response).to redirect_to(inscription_invitation_invalide_path)
  end

  it "redirige vers la page dédiée si l'invitation a déjà été acceptée" do
    invitation = create(:invitation, :acceptee)

    get inscription_nouveau_compte_path(invitation_token: invitation.token)

    expect(response).to redirect_to(inscription_invitation_invalide_path)
  end

  it "redirige aussi vers la page dédiée depuis le flux devise" do
    post compte_registration_path, params: {
      invitation_token: "token-inconnu",
      compte: {
        email: "invite@example.com",
        password: "Password78901$",
        password_confirmation: "Password78901$"
      }
    }

    expect(response).to redirect_to(inscription_invitation_invalide_path)
  end
end
