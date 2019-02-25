# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Administrateur', type: :feature do
  let(:administrateur) { create :administrateur, email: 'administrateur@exemple.fr' }

  context "en tant qu'administrateur" do
    before(:each) { se_connecter_comme_administrateur }

    it 'Ajouter un nouvel administrateur' do
      visit new_admin_administrateur_path
      expect do
        fill_in :administrateur_email, with: 'jeanmarc@exemple?fr'
        fill_in :administrateur_password, with: 'billyjoel'
        fill_in :administrateur_password_confirmation, with: 'billyjoel'
        click_on 'Créer un administrateur'
      end.to change(Administrateur, :count)
    end
  end
end
