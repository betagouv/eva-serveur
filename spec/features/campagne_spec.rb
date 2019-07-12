# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  before { se_connecter_comme_administrateur }
  let!(:campagne) { create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8' }
  let!(:evaluation) { create :evaluation, campagne: campagne }

  describe 'index' do
    before { visit admin_campagnes_path }
    it do
      expect(page).to have_content 'Amiens 18 juin'
      expect(page).to have_content 'A5RC8'
    end
  end

  describe 'création' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Mon QCM' }
    before do
      visit new_admin_campagne_path
      fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
    end

    context 'génère un code si on en saisit pas' do
      before do
        fill_in :campagne_code, with: ''
        select 'Mon QCM'
      end

      it do
        expect { click_on 'Créer' }.to(change { Campagne.count })
        expect(Campagne.last.code).to be_present
        expect(page).to have_content 'Mon QCM'
      end
    end

    context 'conserve le code saisi si précisé' do
      before { fill_in :campagne_code, with: 'EUROCKS' }
      it do
        expect { click_on 'Créer' }.to(change { Campagne.count })
        expect(Campagne.last.code).to eq 'EUROCKS'
      end
    end
  end

  describe 'show' do
    before { visit admin_campagne_path campagne }
    it { expect(page).to have_content 'Roger' }
  end
end
