# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Structure locale', type: :feature do
  describe 'en tant que superadmin' do
    before { se_connecter_comme_superadmin }

    describe 'index' do
      let!(:structure) { create :structure_locale, nom: 'Ma structure' }

      before { visit admin_structures_locales_path }

      it { expect(page).to have_content 'Ma structure' }
    end

    describe 'show' do
      let!(:structure) do
        create :structure_locale, :avec_admin, nom: 'Ma structure', type_structure: 'mission_locale'
      end
      let!(:compte) do
        create :compte, structure: structure, statut_validation: :en_attente, role: :conseiller
      end

      before { visit admin_structure_locale_path(structure) }

      describe 'Ma structure' do
        it { expect(page).to have_content structure.nom }

        it do
          message = 'Ici vous pouvez gérer votre structure et vos collègues ayant accès à eva.'
          expect(page).to have_content message
        end
      end

      describe 'Mes collègues' do
        it 'autorise un compte' do
          click_on 'Autoriser'
          expect(compte.reload.validation_acceptee?).to be true
        end

        it 'refuse un compte' do
          click_on 'Refuser'
          expect(compte.reload.validation_refusee?).to be true
        end
      end
    end

    describe 'create' do
      before { visit new_admin_structure_locale_path }

      it { expect(page).to have_link('Annuler') }

      it 'créé une structure local si on rempli tous les champs' do
        fill_in :structure_locale_nom, with: 'Captive'
        select 'Mission locale'
        fill_in :structure_locale_code_postal, with: '92100'
        click_on 'Créer une structure'

        structure = Structure.order(:created_at).last
        expect(structure.nom).to eq 'Captive'
        expect(structure.type_structure).to eq 'mission_locale'
        expect(structure.code_postal).to eq '92100'
      end
    end

    describe 'modification' do
      before do
        structure = create :structure_locale
        visit edit_admin_structure_locale_path(structure)
        fill_in :structure_locale_nom, with: 'Captive'
        select 'Mission locale'
        fill_in :structure_locale_code_postal, with: '92100'
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

  describe 'avec un compte sans structure' do
    let(:compte) { create(:compte_conseiller, structure: nil) }

    before { connecte(compte) }

    describe 'create' do
      before { visit new_admin_structure_locale_path }

      it { expect(page).not_to have_link('Annuler') }

      it 'assigne la structure crée au compte' do
        fill_in :structure_locale_nom, with: 'Captive'
        select 'Mission locale'
        fill_in :structure_locale_code_postal, with: '92100'
        click_on 'Créer une structure'

        structure = Structure.order(:created_at).last
        expect(compte.reload.structure).to eq structure
      end
    end
  end
end
