# frozen_string_literal: true

require 'rails_helper'

describe 'Création de compte conseiller', type: :feature do
  let!(:structure) { create :structure, :avec_admin, nom: 'Ma structure' }
  let!(:compte_support) do
    create :compte,
           nom: 'Ma structure',
           prenom: 'Véronique',
           telephone: '06 01 02 03 04',
           email: Eva::EMAIL_SUPPORT
  end

  context 'sans structure précisée' do
    before do
      visit new_compte_registration_path
    end

    it "redirige l'utilisateur vers la page pour trouver une structure" do
      expect(page).to have_current_path(structures_path)
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

      infos_support =
        'Vous pouvez contacter Véronique au 06 01 02 03 04 ou par mail à support@eva.beta.gouv.fr'
      expect(page).to have_content infos_support
    end
  end
end
