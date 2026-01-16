require "rails_helper"

describe "Inscription visiteur sans ProConnect", type: :feature do
  let(:email) { "nouvel.utilisateur@example.test" }

  context "quand le formulaire est correctement rempli" do
    it "crée le compte et lance l'onboarding" do
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
      expect(compte.cgu_acceptees).to be(true)
    end
  end
end
