# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Invitation : ce n'est pas la bonne structure", type: :request do
  let!(:structure_invitee) do
    create(:structure_locale, :avec_admin, nom: "Structure invitation", siret: 111_111_111_111_11)
  end
  let!(:autre_structure) do
    create(:structure_locale, :avec_admin, nom: "Autre structure", siret: 130_025_265_000_13)
  end
  let!(:invitation) do
    create(:invitation,
           structure: structure_invitee,
           invitant: create(:compte_admin, structure: structure_invitee),
           email_destinataire: "invite.autre.structure@eva.fr")
  end

  # rubocop:disable RSpec/ExampleLength -- multi-step inscription request flow
  it "permet de saisir un autre SIRET et de rejoindre la structure trouvée" do
    post inscription_nouveau_compte_path, params: {
      invitation_token: invitation.token,
      compte: {
        password: "Pass5678",
        password_confirmation: "Pass5678"
      }
    }
    follow_redirect!

    patch inscription_informations_compte_path, params: {
      compte: {
        nom: "Durand",
        prenom: "Paul",
        email: "invite.autre.structure@eva.fr",
        cgu_acceptees: "1"
      }
    }
    follow_redirect!

    compte = Compte.find_by!(email: "invite.autre.structure@eva.fr")
    expect(compte.etape_inscription).to eq("assignation_structure")

    patch inscription_structure_path, params: { action_type: "recherche" }

    expect(response).to redirect_to(inscription_recherche_structure_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("recherche_structure")
    expect(compte.structure_id).to be_nil

    patch inscription_recherche_structure_path, params: {
      compte: { siret: autre_structure.siret.to_s }
    }
    expect(response).to redirect_to(inscription_structure_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("assignation_structure")
    expect(compte.siret).to eq(autre_structure.siret.to_s)

    patch inscription_structure_path, params: {
      compte: {
        structure_id: autre_structure.id,
        structure_confirmee: "1"
      },
      commit: I18n.t("inscription.structures.show.rejoindre")
    }

    expect(response).to redirect_to(admin_dashboard_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("complet")
    expect(compte.structure).to eq(autre_structure)
  end
  # rubocop:enable RSpec/ExampleLength
end
