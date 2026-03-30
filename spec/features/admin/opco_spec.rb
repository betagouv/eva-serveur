require "rails_helper"

describe "Admin - Opco", type: :feature do
  let!(:opco) { create(:opco, nom: "Mon OPCO") }
  let!(:parcours_type) { create(:parcours_type, libelle: "Parcours visible") }
  let!(:opco_parcours_type) {
 create(:opco_parcours_type, opco: opco, parcours_type: parcours_type) }

  context "en tant que superadmin" do
    let(:compte_superadmin) { create(:compte_superadmin) }

    before { connecte(compte_superadmin) }

    it "affiche les parcours types associés dans le détail d'un opco" do
      visit admin_opco_path(opco)

      expect(page).to have_content("Parcours types associés")
      expect(page).to have_link(parcours_type.libelle)
    end

    it "affiche la section de gestion des parcours types dans le formulaire opco" do
      visit edit_admin_opco_path(opco)

      expect(page).to have_content("Ajouter des parcours types")
      expect(page).to have_content("Ajouter un parcours type")
    end
  end

  context "en tant que chargé de mission régionale" do
    let(:compte_cmr) { create(:compte_charge_mission_regionale, :structure_avec_admin) }

    before { connecte(compte_cmr) }

    it "n'affiche pas la liste des parcours types dans le détail d'un opco" do
      visit admin_opco_path(opco)

      expect(page).to have_content(opco.nom)
      expect(page).not_to have_content("Parcours types associés")
      expect(page).not_to have_link(parcours_type.libelle)
    end

    it "n'a pas accès au formulaire de modification opco" do
      visit edit_admin_opco_path(opco)

      expect(page).to have_content("Vous n'êtes pas autorisé à exécuter cette action")
      expect(page).not_to have_content("Ajouter des parcours types")
    end
  end
end
