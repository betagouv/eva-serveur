# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Compte', type: :feature do
  context "en tant qu'administrateur" do
    before(:each) { se_connecter_comme_administrateur }

    it 'Ajouter un nouvel administrateur' do
      visit new_admin_compte_path
      expect do
        fill_in :compte_email, with: 'jeanmarc@exemple?fr'
        select 'administrateur'
        fill_in :compte_password, with: 'billyjoel'
        fill_in :compte_password_confirmation, with: 'billyjoel'
        click_on 'Créer un compte'
      end.to change(Compte, :count)
    end
  end
end
