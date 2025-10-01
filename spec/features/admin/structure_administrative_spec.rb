require 'rails_helper'

describe 'Admin - Structure administrative', type: :feature do
  let(:compte_courant) { create(:compte_superadmin) }
  let!(:structure) { create :structure_administrative, :avec_admin, nom: 'Ma structure' }

  before { connecte(compte_courant) }

  describe 'index' do
    before { visit admin_structures_administratives_path }

    it { expect(page).to have_content 'Ma structure' }
  end

  describe 'show' do
    let(:statut_validation) { :en_attente }

    let!(:compte) do
      create :compte, structure: structure, statut_validation: statut_validation, role: :conseiller
    end

    before { visit admin_structure_administrative_path(structure) }

    describe 'Ma structure' do
      it { expect(page).to have_content structure.nom }

      it do
        message = 'Ici vous pouvez gérer votre structure et vos collègues ayant accès à eva.'
        expect(page).to have_content message
      end
    end

    context 'en tant que Chargé de mission régionale' do
      let(:compte_courant) { create(:compte_charge_mission_regionale, structure: structure) }

      it { expect(page).to have_content structure.nom }
    end

    context "en tant qu'admin" do
      let(:compte_courant) { create(:compte_admin, structure: structure) }

      it { expect(page).to have_content structure.nom }
    end
  end

  describe 'création' do
    before do
      visit new_admin_structure_administrative_path
      fill_in :structure_administrative_nom, with: 'Eva'
      click_on 'Créer une structure'
    end

    it do
      structure = Structure.order(:created_at).last
      expect(structure.nom).to eq 'Eva'
    end
  end
end
