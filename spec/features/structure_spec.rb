# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Structure', type: :feature do
  context "en tant qu'administrateur" do
    before(:each) { se_connecter_comme_administrateur }

    it 'Ajouter une nouvelle structure' do
      visit new_admin_structure_path
      expect do
        fill_in :structure_nom, with: 'Ma Structure'
        fill_in :structure_code_postal, with: '06000'
        click_on 'Créer une structure'
      end.to change(Structure, :count)
    end
  end
end
