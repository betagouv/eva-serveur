# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Structure administrative', type: :feature do
  before { se_connecter_comme_superadmin }
  let!(:structure) { create :structure_administrative, :avec_admin, nom: 'Ma structure' }

  describe 'index' do
    before { visit admin_structures_administratives_path }

    it { expect(page).to have_content 'Ma structure' }
  end

  describe 'show' do
    let!(:compte) do
      create :compte, structure: structure, statut_validation: :en_attente, role: :conseiller
    end
    before { visit admin_structure_administrative_path(structure) }

    describe 'Ma structure' do
      it { expect(page).to have_content structure.nom }

      it do
        message = 'Ici vous pouvez gérer votre structure et vos collègues ayant accès à eva.'
        expect(page).to have_content message
      end
    end

    describe 'Mes collègues' do
      it 'autorise un compte' do
        click_on 'Autoriser'
        expect(compte.reload.validation_acceptee?).to eq true
      end

      it 'refuse un compte' do
        click_on 'Refuser'
        expect(compte.reload.validation_refusee?).to eq true
      end
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
