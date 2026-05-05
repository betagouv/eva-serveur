require 'rails_helper'

describe 'Admin - Structure Operateur de competence' do
  let(:compte_superadmin) { create(:compte_superadmin) }

  before { connecte(compte_superadmin) }

  describe "index" do
    let!(:structure) { create :structure_opco, nom: 'Structure AFDAS' }

    it "affiche les structures OPCO" do
      visit admin_structures_opcos_path

      expect(page).to have_content 'Structure AFDAS'
    end
  end

  describe "show" do
    let(:structure) { create :structure_opco, :avec_admin, nom: 'Structure AFDAS' }

    before { visit admin_structure_opco_path(structure) }

    describe 'Ma structure' do
      it { expect(page).to have_content structure.nom }

      it do
        message = 'Ici vous pouvez gérer votre structure et vos collègues ayant accès à eva.'
        expect(page).to have_content message
      end
    end

    context "affiche le bloc des statistiques OPCO" do
      it "affiche la section Statistiques avec le dashboard metabase opco" do
        visit admin_structure_opco_path(structure)

        expect(page).to have_css("#bloc-statistiques-opco")
        expect(page).not_to have_css("#bloc-statistiques")
      end
    end

    context "bloc membres - invitation" do
      it "affiche le bouton envoyer une invitation" do
        visit admin_structure_opco_path(structure)

        expect(page).to have_content("Envoyer une invitation")
      end
    end
  end
end
