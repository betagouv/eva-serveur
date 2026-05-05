require 'rails_helper'

describe 'Admin - Structure Operateur de competence', type: :feature do
  describe "index" do
    let(:compte_superadmin) { create(:compte_superadmin) }
    let!(:opco) { create(:opco, nom: "AFDAS") }
    let!(:structure) { create :structure_opco, nom: 'Structure AFDAS', opco: opco }

    before { connecte(compte_superadmin) }

    it "affiche les structures OPCO" do
      visit admin_structures_opcos_path

      expect(page).to have_content 'Structure AFDAS'
    end
  end
end
