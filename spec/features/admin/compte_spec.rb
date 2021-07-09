# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Compte', type: :feature do
  let!(:ma_structure) { create :structure, nom: 'Ma structure' }
  let!(:compte_superadmin) do
    create :compte, structure: ma_structure, email: 'moi@structure'
  end
  let(:compte_connecte) { compte_superadmin }
  let!(:collegue) do
    create :compte_conseiller, structure: ma_structure, email: 'collegue@structure',
                               prenom: 'Collègue'
  end

  before { connecte(compte_connecte) }

  context 'en tant que superadmin' do
    let(:compte_connecte) do
      create :compte_superadmin, structure: ma_structure
    end

    describe 'Je vois mes informations' do
      it do
        visit admin_compte_path(compte_connecte)

        expect(page).to have_content 'Bonjour Prénom !'
        expect(page).to have_content 'Ici vous pouvez gérer votre compte et ' \
                                     'vos informations personnelles.'
      end
    end

    describe 'Je vois les informations d\'un collègue' do
      it do
        visit admin_compte_path(collegue)

        expect(page).not_to have_content 'Bonjour Collègue !'
        expect(page).not_to have_content 'Ici vous pouvez gérer votre compte et ' \
                                         'vos informations personnelles.'
      end
    end

    describe 'Ajouter un nouvel superadmin' do
      it do
        visit new_admin_compte_path
        expect do
          fill_in :compte_prenom, with: 'Jane'
          fill_in :compte_nom, with: 'Doe'
          fill_in :compte_email, with: 'jeanmarc@exemple.fr'
          select 'Superadmin'
          options = ['', 'Superadmin', 'Admin', 'Conseiller', 'Compte générique']
          expect(page).to have_select(:compte_role, options: options)
          select 'Ma structure'
          fill_in :compte_password, with: 'billyjoel'
          fill_in :compte_password_confirmation, with: 'billyjoel'
          click_on 'Créer un compte'
        end.to change(Compte, :count)
        expect(Compte.last.structure).to eq ma_structure
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

  context "en admin d'une structure" do
    let(:compte_connecte) do
      create :compte_admin, structure: ma_structure
    end

    describe "modifier les informations d'un collègue" do
      it do
        visit edit_admin_compte_path(collegue)
        select 'Admin'
        options = ['', 'Admin', 'Conseiller']
        expect(page).to have_select(:compte_role, options: options)

        click_on 'Modifier'

        expect(collegue.reload.role).to eq 'admin'
      end
    end

    describe 'ajouter un collegue' do
      before { visit new_admin_compte_path }

      it do
        fill_in :compte_prenom, with: 'Peppa'
        fill_in :compte_nom, with: 'Pig'
        fill_in :compte_email, with: 'collegue@exemple.fr'
        fill_in :compte_password, with: 'billyjoel'
        fill_in :compte_password_confirmation, with: 'billyjoel'

        expect do
          click_on 'Créer un compte'
        end.to change(Compte, :count)

        compte_cree = Compte.last
        expect(compte_cree.structure).to eq ma_structure
        expect(compte_cree.role).to eq 'conseiller'
      end
    end

    describe 'Refuser un collegue' do
      before do
        visit edit_admin_compte_path(collegue)
        choose 'Refusé'
        click_on 'Modifier'
      end

      it { expect(collegue.reload.validation_refusee?).to be true }
    end

    describe "modifier le mot de passe d'un collègue" do
      before do
        visit edit_admin_compte_path(collegue)
      end

      it { expect(page).not_to have_content('Mot de passe') }
    end
  end

  context 'en conseiller' do
    let(:compte_connecte) do
      create :compte_conseiller, structure: ma_structure, email: 'compte.conseiller@gmail.com'
    end

    describe 'je vois mes collègues' do
      let(:autre_structure) { create :structure, :avec_admin }
      let!(:inconnu) do
        create :compte_conseiller, structure: autre_structure, email: 'inconnu@structure'
      end

      before { visit admin_comptes_path }

      it do
        expect(page).to have_content 'compte.conseiller@gmail.com'
        expect(page).to have_content 'collegue@structure'
        expect(page).to_not have_content 'inconnu@structure'
      end
    end

    describe 'modifier mes informations' do
      before do
        visit edit_admin_compte_path(compte_connecte)
        fill_in :compte_prenom, with: 'Robert'
        fill_in :compte_password, with: 'new_password'
        fill_in :compte_password_confirmation, with: 'new_password'
        click_on 'Modifier'
      end

      it do
        compte_connecte.reload
        expect(compte_connecte.prenom).to eq 'Robert'
        fill_in :compte_email, with: 'new_password'
        fill_in :compte_password, with: 'new_password'
        click_on 'Se connecter'
      end
    end
  end
end
