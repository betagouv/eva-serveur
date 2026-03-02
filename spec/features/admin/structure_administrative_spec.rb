require 'rails_helper'

describe 'Admin - Structure administrative', type: :feature do
  context 'en tant que superadmin' do
    let(:compte_superadmin) { create(:compte_superadmin) }
    let!(:structure) {
          create :structure_administrative, :avec_admin, nom: 'Ma structure',
  siret: '12345678901234'
        }

    before { connecte(compte_superadmin) }

    describe 'index' do
      before { visit admin_structures_administratives_path }

      it { expect(page).to have_content 'Ma structure' }
    end

    describe 'show' do
      let(:statut_validation) { :en_attente }

      let!(:compte) do
        create :compte, structure: structure, statut_validation: statut_validation,
role: :conseiller
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
      it 'permet de créer une structure avec le même SIRET' do
        visit new_admin_structure_administrative_path

        fill_in :structure_administrative_nom, with: 'Nouvelle structure'
        fill_in :structure_administrative_siret, with: '12345678901234'
        click_on 'Créer une structure'

        structure = Structure.order(:created_at).last
        expect(structure.nom).to eq 'Nouvelle structure'
        expect(structure.siret).to eq '12345678901234'
      end
    end

    describe 'modification' do
      let!(:structure_a_modifier) { create(:structure_administrative, siret: '98765432109876') }

      it 'permet de modifier le SIRET pour un SIRET déjà utilisé' do
        visit edit_admin_structure_administrative_path(structure_a_modifier)

        fill_in :structure_administrative_siret, with: '12345678901234'
        click_on 'Modifier'

        structure_a_modifier.reload
        expect(structure_a_modifier.siret).to eq '12345678901234'
      end
    end
  end

  context 'en tant que admin' do
    let!(:structure) { create(:structure_administrative, siret: '12345678901234') }
    let!(:compte_admin) { create(:compte_admin, structure: structure) }

    before { connecte(compte_admin) }

    describe 'create' do
      it 'ne permet pas de créer une structure' do
        visit new_admin_structure_administrative_path

        expect(page).to have_content "Vous n'êtes pas autorisé à exécuter cette action"
      end
    end

    describe 'update' do
      it 'ne permet pas de modifier une structure avec un même SIRET deja affecté' do
        create :structure_administrative, siret: '12345678901212'
        visit edit_admin_structure_administrative_path(structure)
        fill_in :structure_administrative_siret, with: '12345678901212'
        click_on 'Modifier'

        expect(page).to have_content "Ce SIRET est déjà utilisé"
        expect(structure.reload.siret).to eq '12345678901234'
      end
    end
  end
end
