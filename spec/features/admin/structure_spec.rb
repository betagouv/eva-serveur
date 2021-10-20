# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Structure', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:structure) { create :structure, nom: 'Ma structure' }
    before { visit admin_structures_path }

    it { expect(page).to have_content 'Ma structure' }
  end

  describe 'show' do
    let!(:structure) { create :structure, nom: 'Ma structure', type_structure: 'mission_locale' }
    before { visit admin_structure_path(structure) }

    it do
      expect(page).to have_content 'Ma structure'
      expect(page).to have_content 'Mission locale'
    end

    it "autorise un compte" do
      compte = create :compte, structure: structure, statut_validation: :en_attente
      visit admin_structure_path(structure)
      click_on 'autoriser'
      expect(compte.reload.validation_acceptee?).to eq true
    end

    it "refuse un compte" do
      compte = create :compte, structure: structure, statut_validation: :en_attente
      visit admin_structure_path(structure)
      click_on 'refuser'
      expect(compte.reload.validation_refusee?).to eq true
    end
  end

  describe 'modification' do
    before do
      structure = create :structure
      visit edit_admin_structure_path(structure)
      fill_in :structure_nom, with: 'Captive'
      select 'Mission locale'
      fill_in :structure_code_postal, with: '92100'
      click_on 'Modifier'
    end

    it do
      structure = Structure.order(:created_at).last
      expect(structure.nom).to eq 'Captive'
      expect(structure.type_structure).to eq 'mission_locale'
      expect(structure.code_postal).to eq '92100'
    end
  end
end
