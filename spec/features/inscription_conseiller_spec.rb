require 'rails_helper'

describe 'Création de compte conseiller', type: :feature do
  let!(:structure) { create :structure_locale, :avec_admin, nom: 'Ma structure' }

  context 'sans structure précisée' do
    before do
      visit new_compte_registration_path
    end

    it "redirige l'utilisateur vers la page de connexion" do
      expect(page).to have_current_path(new_compte_session_path)
    end
  end

  context "avec un id de structure incorrecte dans l'url" do
    before do
      visit new_compte_registration_path(structure_id: 'random')
    end

    it "redirige l'utilisateur vers la page de connexion" do
      expect(page).to have_current_path(new_compte_session_path)
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

  context "redirection de l'ancien lien d'inscription Devise vers l'embarquement v2" do
    let!(:invitation) do
      invitant = create(:compte_admin, structure: structure)
      create(:invitation,
             structure: structure,
             invitant: invitant,
             email_destinataire: "redirect-test@eva.fr")
    end

    it "redirige vers inscription/nouveau_compte avec le token" do
      visit new_compte_registration_path(invitation_token: invitation.token)
      expect(page).to have_current_path(
        inscription_nouveau_compte_path(invitation_token: invitation.token),
        ignore_query: false
      )
    end
  end

  context "avec un lien d'invitation (token à usage unique)" do
    let!(:invitation) do
      invitant = create(:compte_admin, structure: structure)
      create(:invitation,
             structure: structure,
             invitant: invitant,
             email_destinataire: "monemail-invitation@eva.fr")
    end

    before do
      visit inscription_nouveau_compte_path(invitation_token: invitation.token)
      fill_in :compte_password, with: 'Pass5678'
      fill_in :compte_password_confirmation, with: 'Pass5678'
    end

    it "crée un compte actif sans validation Admin et marque l'invitation comme acceptée" do
      expect do
        click_on "Créer mon compte"
      end.to change(Compte, :count).by(1)

      expect(page).to have_current_path(inscription_informations_compte_path)

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
                         invitant: create(:compte_admin, structure: structure), role: "admin",
                         email_destinataire: "admin-invite@eva.fr")
    end

    before do
      visit inscription_nouveau_compte_path(invitation_token: invitation.token)
      fill_in :compte_password, with: "Pass5678"
      fill_in :compte_password_confirmation, with: "Pass5678"
    end

    it "crée un compte avec le rôle admin choisi lors de l'invitation" do
      expect do
        click_on "Créer mon compte"
      end.to change(Compte, :count).by(1)

      expect(page).to have_current_path(inscription_informations_compte_path)

      nouveau_compte = Compte.find_by email: "admin-invite@eva.fr"
      expect(nouveau_compte.role).to eq "admin"
      expect(nouveau_compte.structure).to eq structure
      expect(nouveau_compte.validation_acceptee?).to be true
    end
  end

  context "avec une invitation envoyée par un conseiller" do
    let!(:conseiller_invitant) { create(:compte_conseiller, structure: structure) }
    let!(:invitation) do
      create(:invitation, structure: structure, invitant: conseiller_invitant, role: "conseiller",
                         email_destinataire: "invitee-conseiller@eva.fr")
    end

    before do
      visit inscription_nouveau_compte_path(invitation_token: invitation.token)
      fill_in :compte_password, with: "Pass5678"
      fill_in :compte_password_confirmation, with: "Pass5678"
    end

    it "crée un compte en attente quand l'invitation est envoyée par un conseiller" do
      expect do
        click_on "Créer mon compte"
      end.to change(Compte, :count).by(1)

      expect(page).to have_current_path(inscription_informations_compte_path)

      nouveau_compte = Compte.find_by email: "invitee-conseiller@eva.fr"
      expect(nouveau_compte.validation_en_attente?).to be true
      expect(nouveau_compte.role).to eq "conseiller"
      expect(nouveau_compte.structure).to eq structure

      invitation.reload
      expect(invitation.statut).to eq "acceptee"
      expect(invitation.compte_id).to eq nouveau_compte.id
    end
  end

  context "lien d'invitation invalide ou déjà utilisé" do
    it "redirige avec un message d'erreur quand le token est inconnu" do
      visit inscription_nouveau_compte_path(invitation_token: "token-inexistant")
      expect(page).to have_current_path(inscription_invitation_invalide_path)
      expect(page).to have_content("n’est pas valide ou a déjà été utilisé")
      expect(page).to have_link("Aller à l’accueil pour se connecter",
href: new_compte_session_path)
    end

    it "redirige avec un message d'erreur quand l'invitation est déjà acceptée" do
      invitation = create(:invitation, :acceptee, structure: structure)
      visit inscription_nouveau_compte_path(invitation_token: invitation.token)
      expect(page).to have_current_path(inscription_invitation_invalide_path)
      expect(page).to have_content("n’est pas valide ou a déjà été utilisé")
    end

    it "redirige depuis l'ancien URL Devise quand le token est inconnu" do
      visit new_compte_registration_path(invitation_token: "token-inexistant")
      expect(page).to have_current_path(inscription_invitation_invalide_path)
      expect(page).to have_content("n’est pas valide ou a déjà été utilisé")
    end
  end
end
