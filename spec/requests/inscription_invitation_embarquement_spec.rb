# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Parcours d'embarquement après invitation", type: :request do
  let!(:structure) { create(:structure_locale, :avec_admin, nom: "Structure invitante") }
  let!(:invitation) do
    create(:invitation,
           structure: structure,
           invitant: create(:compte_admin, structure: structure),
           email_destinataire: "invite.embarquement@eva.fr")
  end

  it "mène au tableau de bord après confirmation de la structure proposée" do
    post inscription_nouveau_compte_path, params: {
      invitation_token: invitation.token,
      compte: {
        password: "Pass5678",
        password_confirmation: "Pass5678"
      }
    }

    expect(response).to redirect_to(inscription_informations_compte_path)
    follow_redirect!

    compte = Compte.find_by!(email: "invite.embarquement@eva.fr")
    expect(compte.etape_inscription).to eq("preinscription")

    patch inscription_informations_compte_path, params: {
      compte: {
        nom: "Martin",
        prenom: "Claire",
        email: "invite.embarquement@eva.fr",
        cgu_acceptees: "1"
      }
    }

    expect(response).to redirect_to(inscription_structure_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("assignation_structure")
    expect(response.body).not_to include(I18n.t("inscription.structures.show.mention_acces"))

    patch inscription_structure_path, params: {
      compte: {
        structure_id: structure.id,
        structure_confirmee: "1"
      },
      commit: I18n.t("inscription.structures.show.rejoindre")
    }

    expect(response).to redirect_to(admin_dashboard_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("complet")
    expect(compte.structure).to eq(structure)
  end

  it "mène au tableau de bord sur la structure d'invitation si une autre fiche partage le SIRET" do
    autre_fiche = create(:structure_locale, nom: "Autre fiche historique doublon SIRET",
                                           siret: 999_999_999_999_99)
    autre_fiche.update_columns(siret: structure.siret)
    expect(Structure.avec_meme_siret_que(structure.siret).count).to eq(2)

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
        nom: "Martin",
        prenom: "Claire",
        email: "invite.embarquement@eva.fr",
        cgu_acceptees: "1"
      }
    }
    expect(response).to redirect_to(inscription_structure_path)
    follow_redirect!

    compte = Compte.find_by!(email: "invite.embarquement@eva.fr")
    expect(compte.etape_inscription).to eq("assignation_structure")

    patch inscription_structure_path, params: {
      compte: {
        structure_id: structure.id,
        structure_confirmee: "1"
      },
      commit: I18n.t("inscription.structures.show.rejoindre")
    }

    expect(response).to redirect_to(admin_dashboard_path)
    follow_redirect!

    compte.reload
    expect(compte.etape_inscription).to eq("complet")
    expect(compte.structure_id).to eq(structure.id)
    expect(compte.structure).to eq(structure)
  end
end
