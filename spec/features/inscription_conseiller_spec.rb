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

    it "crée un compte" do
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

  context "avec un lien d'invitation (token à usage unique)" do
    let!(:invitation) {
 create(:invitation, structure: structure, invitant: create(:compte_admin, structure: structure)) }

    before do
      visit new_compte_registration_path(invitation_token: invitation.token)
      fill_in :compte_prenom, with: 'Julia'
      fill_in :compte_nom, with: 'Robert'
      fill_in :compte_email, with: 'monemail-invitation@eva.fr'
      fill_in :compte_password, with: 'Pass5678'
      fill_in :compte_password_confirmation, with: 'Pass5678'
      check("compte_cgu_acceptees", allow_label_click: true)
    end

    it "crée un compte actif sans validation Admin et marque l'invitation comme acceptée" do
      expect do
        click_on "S'inscrire"
      end.to change(Compte, :count).by(1)

      nouveau_compte = Compte.find_by email: 'monemail-invitation@eva.fr'
      expect(nouveau_compte.validation_acceptee?).to be true
      expect(nouveau_compte.role).to eq "conseiller"
      expect(nouveau_compte.structure).to eq structure

      invitation.reload
      expect(invitation.statut).to eq "acceptee"
      expect(invitation.compte_id).to eq nouveau_compte.id
    end
  end

  context "avec une invitation au rôle Administrateur" do
    let!(:invitation) do
      create(:invitation, structure: structure,
invitant: create(:compte_admin, structure: structure), role: "admin")
    end

    before do
      visit new_compte_registration_path(invitation_token: invitation.token)
      fill_in :compte_prenom, with: "Paul"
      fill_in :compte_nom, with: "Dupont"
      fill_in :compte_email, with: "admin-invite@eva.fr"
      fill_in :compte_password, with: "Pass5678"
      fill_in :compte_password_confirmation, with: "Pass5678"
      check("compte_cgu_acceptees", allow_label_click: true)
    end

    it "crée un compte avec le rôle admin choisi lors de l'invitation" do
      expect do
        click_on "S'inscrire"
      end.to change(Compte, :count).by(1)

      nouveau_compte = Compte.find_by email: "admin-invite@eva.fr"
      expect(nouveau_compte.role).to eq "admin"
      expect(nouveau_compte.structure).to eq structure
      expect(nouveau_compte.validation_acceptee?).to be true
    end
  end

  context "lien d'invitation invalide ou déjà utilisé" do
    it "redirige avec un message d'erreur quand le token est inconnu" do
      visit new_compte_registration_path(invitation_token: "token-inexistant")
      expect(page).to have_current_path(structures_path)
      expect(page).to have_content("n'est pas valide ou a déjà été utilisé")
    end

    it "redirige avec un message d'erreur quand l'invitation est déjà acceptée" do
      invitation = create(:invitation, :acceptee, structure: structure)
      visit new_compte_registration_path(invitation_token: invitation.token)
      expect(page).to have_current_path(structures_path)
      expect(page).to have_content("n'est pas valide ou a déjà été utilisé")
    end
  end
end
