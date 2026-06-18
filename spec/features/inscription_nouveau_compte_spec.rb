require "rails_helper"

describe "Inscription visiteur sans ProConnect", type: :feature do
  let(:email) { "nouvel.utilisateur@example.test" }

  context "quand structure_id est passé en paramètre" do
    let!(:structure) { create(:structure_locale, :avec_admin) }

    it "crée le compte avec la structure associée en lance l'embarquement" do
      visit inscription_nouveau_compte_path(structure_id: structure.id)

      fill_in "compte_email", with: email
      fill_in "compte_password", with: "Password78901$"
      fill_in "compte_password_confirmation", with: "Password78901$"

      click_on "Créer mon compte"

      expect(page).to have_current_path(inscription_informations_compte_path)

      compte = Compte.find_by(email: email)
      expect(compte).to be_present
      expect(compte.structure).to eq(structure)
      expect(compte.role).to eq("conseiller")
      expect(compte.statut_validation).to eq("en_attente")
      expect(compte.etape_inscription).to eq("preinscription")
    end
  end

  it "affiche le hint indiquant au moins 8 caractères" do
    visit inscription_nouveau_compte_path

    expect(page).to have_content("doit comporter au moins 8 caractères")
  end

  context "par defaut" do
    it "crée le compte et lance l'embarquement" do
      visit inscription_nouveau_compte_path
      expect(page).to have_field("compte_email")
      expect(page).to have_field("compte_password")
      expect(page).to have_field("compte_password_confirmation")

      fill_in "compte_email", with: email
      fill_in "compte_password", with: "Password78901$"
      fill_in "compte_password_confirmation", with: "Password78901$"

      click_on "Créer mon compte"

      expect(page).to have_current_path(inscription_informations_compte_path)

      compte = Compte.find_by(email: email)
      expect(compte).to be_present
      expect(compte.structure).to be_nil
      expect(compte.role).to eq("conseiller")
      expect(compte.statut_validation).to eq("en_attente")
      expect(compte.etape_inscription).to eq("preinscription")
    end
  end
end
