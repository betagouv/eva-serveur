require 'rails_helper'

describe 'Création de compte conseiller', type: :feature do
  let!(:structure) { create :structure_locale, :avec_admin, nom: 'Ma structure' }

  context 'sans structure précisée' do
    before do
      visit new_compte_registration_path
    end

    it "redirige l'utilisateur vers la page pour trouver une structure" do
      expect(page).to have_current_path(structures_path)
    end
  end

  context "avec un id de structure incorrecte dans l'url" do
    before do
      visit new_compte_registration_path(structure_id: 'random')
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
      fill_in :compte_password, with: 'Pass5678'
      fill_in :compte_password_confirmation, with: 'Pass5678'
      check("J’accepte les conditions générales d’utilisation", allow_label_click: true)
    end

    it do
      expect do
        click_on "S'inscrire"
      end.to change(Compte, :count).by(1)
                                   .and(change(Devise.mailer.deliveries, :count).by(1))
      nouveau_compte = Compte.find_by email: 'monemail@eva.fr'
      expect(nouveau_compte.validation_en_attente?).to be true
      expect(nouveau_compte.structure).to eq structure
      expect(nouveau_compte.cgu_acceptees).to be true
    end
  end

  context 'structure sans admin' do
    let!(:structure_sans_admin) { create :structure_locale, nom: 'Ma structure sans admin' }

    before do
      visit new_compte_registration_path(structure_id: structure_sans_admin.id)
      fill_in :compte_prenom, with: 'Julia'
      fill_in :compte_nom, with: 'Robert'
      fill_in :compte_email, with: 'monemail@eva.fr'
      fill_in :compte_password, with: 'Pass5678'
      fill_in :compte_password_confirmation, with: 'Pass5678'
    end

    it 'donne le role admin' do
      click_on "S'inscrire"
      nouveau_compte = Compte.find_by email: 'monemail@eva.fr'
      expect(nouveau_compte.validation_en_attente?).to be false
      expect(nouveau_compte.role).to eq 'admin'
    end
  end
end
