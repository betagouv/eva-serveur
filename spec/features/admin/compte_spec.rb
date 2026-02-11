require 'rails_helper'

describe 'Admin - Compte', type: :feature do
  let!(:ma_structure) { create :structure_locale, nom: 'Ma structure', code_postal: '75012' }
  let!(:compte_superadmin) do
    create :compte_superadmin, structure: ma_structure, email: 'moi@structure'
  end
  let!(:collegue) do
    create :compte_conseiller, structure: ma_structure, email: 'collegue@structure',
                               prenom: 'Collègue'
  end

  before { connecte(compte_connecte) }

  describe 'index' do
    let(:compte_connecte) { compte_superadmin }

    before { visit admin_comptes_path }

    it { expect(page).to have_content 'moi@structure' }
  end

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

    describe 'Je peux voir le champ Accès dans le formulaire' do
      it "n'apparaît pas pour mon compte" do
        visit edit_admin_compte_path(compte_connecte)

        expect(page).not_to have_content 'Accès'
        expect(page).not_to have_content 'Autorisé'
        expect(page).not_to have_content 'Refusé'
      end

      it 'apparaît pour un autre compte' do
        visit edit_admin_compte_path(collegue)

        expect(page).to have_content 'Accès'
        expect(page).to have_content 'Autorisé'
        expect(page).to have_content 'Refusé'
      end
    end

    describe 'Refuser un collègue conseiller' do
      before do
        visit edit_admin_compte_path(collegue)
        choose 'Refusé'
        click_on 'Modifier'
      end

      it { expect(collegue.reload.validation_refusee?).to be true }
    end

    describe 'Je vois les informations d\'un collègue' do
      it do
        visit admin_compte_path(collegue)

        expect(page).not_to have_content 'Bonjour Collègue !'
        expect(page).not_to have_content 'Ici vous pouvez gérer votre compte et ' \
                                         'vos informations personnelles.'
      end
    end

    describe 'Ajouter un nouveau superadmin' do
      it do
        visit new_admin_compte_path
        expect do
          fill_in :compte_prenom, with: 'Jane'
          fill_in :compte_nom, with: 'Doe'
          fill_in :compte_email, with: 'jeanmarc@exemple.fr'
          select 'Superadmin'
          options = [ '', 'Conseiller', 'Admin', 'Chargé de Mission Régionale', 'Superadmin',
                     'Compte générique' ]
          expect(page).to have_select(:compte_role, options: options)
          select 'Ma structure'
          fill_in :compte_password, with: 'billyJoel123$$$'
          fill_in :compte_password_confirmation, with: 'billyJoel123$$$'
          click_on 'Créer un compte'
        end.to change(Compte, :count)
        expect(Compte.last.structure).to eq ma_structure
      end
    end

    describe 'mettre à jour sans mot de passe' do
      let!(:compte) { create :compte, prenom: 'John' }

      it do
        visit edit_admin_compte_path(compte)
        fill_in :compte_prenom, with: 'David'
        click_on 'Modifier'
        expect(compte.reload.prenom).to eq 'David'
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
        options = [ '', 'Admin', 'Conseiller' ]
        expect(page).to have_select(:compte_role, options: options)
        expect(page).to have_content 'Accès'

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
        fill_in :compte_password, with: 'billyjoel123$$$'
        fill_in :compte_password_confirmation, with: 'billyjoel123$$$'

        expect do
          click_on 'Créer un compte'
        end.to change(Compte, :count)

        compte_cree = Compte.last
        expect(compte_cree.structure).to eq ma_structure
        expect(compte_cree.role).to eq 'conseiller'
      end
    end

    describe 'Refuser un collègue conseiller' do
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

    describe 'lorsque je clique sur le bouton annuler du formulaire' do
      it 'annule une création de compte' do
        visit new_admin_compte_path
        click_on 'Annuler'

        expect(page).to have_current_path(admin_comptes_path, ignore_query: true)
      end

      it 'annule une modification' do
        visit edit_admin_compte_path(compte_connecte)
        click_on 'Annuler'

        expect(page).to have_current_path(admin_compte_path(compte_connecte), ignore_query: true)
      end
    end
  end

  context 'en conseiller' do
    let(:compte_connecte) do
      create :compte_conseiller, structure: ma_structure, email: 'compte.conseiller@gmail.com'
    end

    describe 'je vois mes collègues' do
      let(:autre_structure) { create :structure_locale, :avec_admin }
      let!(:inconnu) do
        create :compte_conseiller, structure: autre_structure, email: 'inconnu@structure'
      end

      before { visit admin_comptes_path }

      it do
        expect(page).to have_content 'compte.conseiller@gmail.com'
        expect(page).to have_content 'collegue@structure'
        expect(page).not_to have_content 'inconnu@structure'
      end
    end

    describe 'modifier mes informations' do
      before do
        visit edit_admin_compte_path(compte_connecte)
        fill_in :compte_prenom, with: 'Robert'
        fill_in :compte_password, with: 'new_password123$$$'
        fill_in :compte_password_confirmation, with: 'new_password123$$$'
        click_on 'Modifier'
      end

      it do
        compte_connecte.reload
        expect(compte_connecte.prenom).to eq 'Robert'
        fill_in :compte_email, with: 'new_password'
        fill_in :compte_password, with: 'new_password123$$$'
        click_on 'Se connecter'
      end
    end

    describe 'mise à jour du statut de validation' do
      it 'ne voit pas les champs Statut et Rôle' do
        visit edit_admin_compte_path(compte_connecte)

        expect(page).not_to have_content('Accès')
        expect(page).not_to have_content('Autorisé')
        expect(page).not_to have_content('Refusé')
        expect(page).not_to have_content('Conseiller')
      end
    end
  end

  context 'avec un compte sans structure' do
    let(:compte_connecte) do
      create :compte_conseiller, :en_attente, structure: nil
    end

    it 'peut rejoindre une structure' do
      visit admin_recherche_structure_path(
        ville_ou_code_postal: 'Paris+(75012)',
        code_postal: '75012'
      )
      click_on 'Rejoindre'
      expect(page).to have_current_path admin_dashboard_path
      expect(compte_connecte.reload.structure).to eq ma_structure
      expect(compte_connecte.role).to eq 'conseiller'
    end

    it "revient sur la page de recherche si la structure n'existe plus" do
      visit admin_recherche_structure_path(
        ville_ou_code_postal: 'Paris+(75012)',
        code_postal: '75012'
      )
      ma_structure.destroy
      click_on 'Rejoindre'
      expect(page).to have_current_path admin_recherche_structure_path
    end

    context 'avec une structure sans admin' do
      let!(:nouvelle_structure) { create :structure_locale, code_postal: '67000' }

      it 'devient admin de la structure' do
        visit admin_recherche_structure_path(
          ville_ou_code_postal: 'Strasbourg(67000)',
          code_postal: '67000'
        )
        find(:xpath, "(//a[text()='Rejoindre'])[1]").click
        expect(page).to have_current_path admin_dashboard_path
        expect(compte_connecte.reload.structure).to eq nouvelle_structure
        expect(compte_connecte.role).to eq 'admin'
      end
    end
  end

  describe '#show' do
    let(:compte_connecte) { compte_superadmin }

    context "quand le compte connecté a fait une demande pour changer d'email" do
      before do
        compte_connecte.update unconfirmed_email: 'nouvel-email@exemple.fr'
        visit admin_compte_path(compte_connecte)
      end

      it { expect(page).to have_content(/nouvel-email@exemple.fr/) }

      it do
        expect(page).to have_content(/Consultez votre boîte de réception,/)
      end
    end

    describe "pour un compte connecté qui n'a jamais été confirmé" do
      before { compte_connecte.update confirmed_at: nil }

      context 'quand je suis sur la show de mon compte' do
        before { visit admin_compte_path(compte_connecte) }

        it { expect(page).to have_content(/Confirmez votre adresse email/) }

        it 'redirige vers la page de renvoi des instructions avec mon adresse email pré-rempli' do
          click_on 'Renvoyer les instructions de confirmation'

          expect(page).to have_current_path(
            new_compte_confirmation_path(email: compte_connecte.email_a_confirmer)
          )
        end
      end

      context "quand je suis sur la show d'un autre compte" do
        before { visit admin_compte_path(collegue) }

        it { expect(page).not_to have_content(/Confirmez votre adresse email/) }
      end

      context "quand l'email du compte d'un collègue a été modifié" do
        before do
          collegue.update(unconfirmed_email: 'new_email@test.com')
          visit admin_compte_path(collegue)
        end

        it { expect(page).to have_content(/Une demande de modification d’email a été effectuée./) }
      end
    end

    describe "quand le compte connecté visite la page compte d'un collègue non confirmé" do
      before do
        collegue.update confirmed_at: nil
        visit admin_compte_path(collegue)
      end

      it "redirige vers la page de renvoi des instructions avec l'adresse email pré-rempli" do
        click_on 'Renvoyer l’email de confirmation'

        expect(page).to have_current_path(
          new_compte_confirmation_path(email: collegue.email_a_confirmer)
        )
      end
    end
  end
end
