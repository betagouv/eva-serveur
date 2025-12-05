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

  context 'quand le conseiller se connecte par ProConnect' do
    let(:siret) { '11111111111111' }
    let!(:compte_pro_connect) do
      create(
        :compte_pro_connect,
        email: 'conseiller@example.fr',
        prenom: 'Jean',
        nom: 'Dupont',
        siret_pro_connect: siret,
        structure: nil
      )
    end

    before do
      inscription_pro_connect(compte_pro_connect)
    end

    it 'permet de compléter ses informations' do
      # Mock de l'API Sirene pour retourner des infos de structure
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Sirene::Client).to receive(:recherche).and_return(
        {
          "results" => [ {
            "siege" => {
              "siret" => siret,
              "adresse" => "1 rue de la Paix, 75001 Paris"
            },
            "nom_raison_sociale" => "Entreprise Test",
            "activite_principale" => "6201Z"
          } ]
        }
      )
      # rubocop:enable RSpec/AnyInstance

      # Vérifie qu'on est bien sur la page d'informations de compte
      expect(page).to have_current_path(inscription_informations_compte_path)
      expect(page).to have_content('Informations personnelles')

      # Vérifie que les champs sont pré-remplis avec les infos ProConnect
      expect(page).to have_field('Nom', with: 'Dupont')
      expect(page).to have_field('Prénom', with: 'Jean')
      expect(page).to have_field('Email', with: 'conseiller@example.fr')

      # Complète les informations manquantes
      select 'Conseillère ou conseiller emploi / formation / insertion', from: 'Fonction'
      fill_in 'Service/Département', with: 'Service RH'
      check 'compte_cgu_acceptees'
      click_on 'Valider'

      # Avec un SIRET, on est redirigé vers la page de création de structure
      expect(page).to have_current_path(inscription_structure_path)

      # Vérifie que le compte a été mis à jour avec les nouvelles informations
      compte_pro_connect.reload
      expect(compte_pro_connect.fonction).to eq(
        'conseillere_ou_conseiller_emploi_formation_insertion'
      )
      expect(compte_pro_connect.service_departement).to eq('Service RH')
      expect(compte_pro_connect.cgu_acceptees).to be true
      expect(compte_pro_connect.etape_inscription).to eq "assignation_structure"
    end

    context "quand le siret pro connect correspond à une structure existante" do
      let(:siret) { '13002526500013' }
      let!(:structure_avec_admin) {
 create :structure_locale, :avec_admin, nom: 'Ma structure avec admin', siret: siret }
      let!(:compte_pro_connect) do
        create(
          :compte_pro_connect,
          email: 'conseiller@example.fr',
          prenom: 'Jean',
          nom: 'Dupont',
          siret_pro_connect: siret,
          structure: structure_avec_admin
        )
      end

      it "redirige vers la page d'assignation de structure" do
        select 'Conseillère ou conseiller emploi / formation / insertion', from: 'Fonction'
        fill_in 'Service/Département', with: 'Service RH'
        check 'compte_cgu_acceptees'
        click_on 'Valider'
        expect(page).to have_current_path(inscription_structure_path)
        expect(page).to have_content('Rejoindre')
      end
    end

    context "quand le siret pro connect ne correspond à aucune structure" do
      let(:siret) { '13002526500013' }
      let!(:compte_pro_connect) do
        create(
          :compte_pro_connect,
          email: 'conseiller@example.fr',
          prenom: 'Jean',
          nom: 'Dupont',
          siret_pro_connect: siret,
          structure: nil
        )
      end

      before do
        # Mock de l'API Sirene pour retourner des infos de structure
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Sirene::Client).to receive(:recherche).and_return(
          {
            "results" => [ {
              "siege" => {
                "siret" => siret,
                "adresse" => "1 rue de la Paix 75001 Paris"
              },
              "nom_raison_sociale" => "Entreprise Test",
              "nom_complet" => "Entreprise Test",
              "activite_principale" => "6201Z",
              "complements" => {
                "liste_idcc" => []
              }
            } ]
          }
        )
        # rubocop:enable RSpec/AnyInstance
        inscription_pro_connect(compte_pro_connect)
      end

      it "affiche le formulaire de création de structure avec les infos pré-remplies" do
        select 'Conseillère ou conseiller emploi / formation / insertion', from: 'Fonction'
        fill_in 'Service/Département', with: 'Service RH'
        check 'compte_cgu_acceptees'
        click_on 'Valider'

        expect(page).to have_current_path(inscription_structure_path)
        expect(page).to have_content('Création de votre structure')
        expect(page).to have_content(siret)
        expect(page).to have_select('Type de structure')
        expect(page).to have_button('Créer ma structure')
      end

      it "permet de créer la structure" do
        select 'Conseillère ou conseiller emploi / formation / insertion', from: 'Fonction'
        fill_in 'Service/Département', with: 'Service RH'
        check 'compte_cgu_acceptees'
        click_on 'Valider'

        expect(page).to have_current_path(inscription_structure_path)

        fill_in 'Nom de la structure', with: 'Ma Nouvelle Structure'
        select 'Mission locale', from: 'Type de structure'

        expect do
          click_on 'Créer ma structure'
        end.to change(Structure, :count).by(1)

        expect(page).to have_current_path(admin_dashboard_path)

        nouvelle_structure = Structure.last
        expect(nouvelle_structure.siret).to eq(siret)
        expect(nouvelle_structure.nom).to eq('Ma Nouvelle Structure')
        expect(nouvelle_structure.type_structure).to eq('mission_locale')
        expect(nouvelle_structure.code_postal).to eq(StructureLocale::TYPE_NON_COMMUNIQUE)

        compte_pro_connect.reload
        expect(compte_pro_connect.structure).to eq(nouvelle_structure)
        expect(compte_pro_connect.role).to eq('admin')
        expect(compte_pro_connect.etape_inscription).to eq('complet')
      end
    end
  end
end
