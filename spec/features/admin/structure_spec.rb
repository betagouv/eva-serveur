# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Structure', type: :feature do
  before { se_connecter_comme_administrateur }

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
