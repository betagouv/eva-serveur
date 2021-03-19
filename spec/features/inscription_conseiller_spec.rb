# frozen_string_literal: true

require 'rails_helper'

describe 'Création de compte conseiller', type: :feature do
  let!(:structure) { create :structure, nom: 'Ma structure' }

  context 'sans structure précisée' do
    before do
      visit new_compte_registration_path
      fill_in :compte_prenom, with: 'Julia'
      fill_in :compte_nom, with: 'Robert'
      fill_in :compte_email, with: 'monemail@eva.fr'
      fill_in :compte_telephone, with: '01 02 03 04 05'
      fill_in :compte_password, with: 'Pass123'
      fill_in :compte_password_confirmation, with: 'Pass123'
      select 'Ma structure'
    end

    it do
      expect { click_on "S'inscrire" }.to change(Compte, :count).by 1

      nouveau_compte = Compte.find_by email: 'monemail@eva.fr'
      expect(nouveau_compte.validation_en_attente?).to be true
      expect(nouveau_compte.structure).to eq structure
      expect(nouveau_compte.telephone).to eq '01 02 03 04 05'
    end
  end

  context "structure précisée dans l'url" do
    before do
      visit new_compte_registration_path(structure_id: structure.id)
      fill_in :compte_prenom, with: 'Julia'
      fill_in :compte_nom, with: 'Robert'
      fill_in :compte_email, with: 'monemail@eva.fr'
      fill_in :compte_password, with: 'Pass123'
      fill_in :compte_password_confirmation, with: 'Pass123'
    end

    it do
      expect { click_on "S'inscrire" }.to change(Compte, :count).by 1

      nouveau_compte = Compte.find_by email: 'monemail@eva.fr'
      expect(nouveau_compte.validation_en_attente?).to be true
      expect(nouveau_compte.structure).to eq structure
    end
  end
end
