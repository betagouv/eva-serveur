# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  before { se_connecter_comme_administrateur }

  describe 'index' do
    let!(:campagne) { create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8' }
    before { visit admin_campagnes_path }
    it do
      expect(page).to have_content 'Amiens 18 juin'
      expect(page).to have_content 'A5RC8'
    end
  end

  describe 'création' do
    before do
      visit new_admin_campagne_path
      fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
      fill_in :campagne_code, with: 'EUROCK'
    end

    it { expect { click_on 'Créer' }.to(change { Campagne.count }) }
  end
end
