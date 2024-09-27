# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Situation', type: :feature do
  before { se_connecter_comme_superadmin }

  let!(:tri) { create :situation_tri, libelle: 'Situation Tri' }

  describe 'index' do
    before { visit admin_situations_path }

    it { expect(page).to have_content 'Situation Tri' }
  end

  describe '#show' do
    before { visit admin_situation_path(tri) }

    it { expect(page).to have_content 'Situation Tri' }
  end

  describe 'création' do
    before do
      visit new_admin_situation_path
      fill_in :situation_libelle, with: 'Inventaire'
      fill_in :situation_nom_technique, with: 'inventaire'
    end

    it { expect { click_on 'Créer' }.to(change(Situation, :count)) }
  end
end
