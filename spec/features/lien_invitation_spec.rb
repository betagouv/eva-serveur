require "rails_helper"

describe "Lien d'invitation structure", type: :feature do
  let!(:structure) { create(:structure_locale) }

  it "affiche le formulaire d'invitation historique" do
    visit new_compte_registration_path(structure_id: structure.id)

    expect(page).to have_current_path(new_compte_registration_path(structure_id: structure.id))
    expect(page).to have_field("compte_email")
    expect(page).to have_field("compte_password")
    expect(page).to have_field("compte_password_confirmation")
  end
end
