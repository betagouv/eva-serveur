# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Compte', type: :feature do
  context "en tant qu'administrateur" do
    before(:each) { se_connecter_comme_administrateur }

    describe 'Ajouter un nouvel administrateur' do
      let!(:structure) { create :structure, nom: 'Ma Super Structure' }

      it do
        visit new_admin_compte_path
        expect do
          fill_in :compte_email, with: 'jeanmarc@exemple.fr'
          select 'administrateur'
          select 'Ma Super Structure'
          fill_in :compte_password, with: 'billyjoel'
          fill_in :compte_password_confirmation, with: 'billyjoel'
          click_on 'Créer un compte'
        end.to change(Compte, :count)
        expect(Compte.last.structure).to eq structure
      end
    end

    describe 'mettre à jour sans mot de passe' do
      let!(:compte) { create :compte, email: 'debut@test.com' }
      it do
        visit edit_admin_compte_path(compte)
        fill_in :compte_email, with: 'fin@test.com'
        click_on 'Modifier'
        expect(compte.reload.email).to eq 'fin@test.com'
      end
    end
  end

  context 'en conseiller' do
    let(:ma_structure) { create :structure }
    let(:autre_structure) { create :structure }
    let(:conseiller_connecte) do
      create :compte_organisation, structure: ma_structure, email: 'moi@structure'
    end
    let!(:collegue) do
      create :compte_organisation, structure: ma_structure, email: 'collegue@structure'
    end
    let!(:inconnu) do
      create :compte_organisation, structure: autre_structure, email: 'inconnu@structure'
    end

    before(:each) { connecte conseiller_connecte }

    describe 'je vois mes collègues' do
      before { visit admin_comptes_path }

      it do
        expect(page).to have_content 'moi@structure'
        expect(page).to have_content 'collegue@structure'
        expect(page).to_not have_content 'inconnu@structure'
      end
    end
  end
end
