require 'rails_helper'

describe 'Recherche de structure par SIRET', type: :feature do
  let(:siret) { '13002526500013' }
  let!(:compte_pro_connect) do
    create(
      :compte_pro_connect,
      email: 'conseiller@example.fr',
      prenom: 'Jean',
      nom: 'Dupont',
      siret_pro_connect: nil, # Pas de SIRET dans ProConnect
      structure: nil,
      etape_inscription: 'recherche_structure'
    )
  end

  before do
    inscription_pro_connect(compte_pro_connect)
  end

  context "quand le compte n'a pas de SIRET ProConnect" do
    before do
      # On visite directement la page car le compte est déjà en étape recherche_structure
      visit inscription_recherche_structure_path
    end

    it 'affiche le formulaire de recherche de structure par SIRET' do
      expect(page).to have_current_path(inscription_recherche_structure_path)
      expect(page).to have_content('Dans quelle structure travaillez-vous ?')
      expect(page).to have_content('Rechercher ma structure')
      expect(page).to have_field('siret')
      expect(page).to have_link('Retrouver votre SIRET sur l\'Annuaire des Entreprises')
    end

    context 'avec un SIRET correspondant à une structure existante' do
      let!(:structure_existante) do
        create(:structure_locale, :avec_admin, siret: siret, nom: 'Ma structure existante')
      end

      before do
        visit inscription_recherche_structure_path
      end

      it 'permet de rechercher et rejoindre la structure' do
        fill_in 'siret', with: siret
        click_on 'Valider'

        expect(page).to have_current_path(inscription_structure_path)
        expect(page).to have_content('Rejoindre une structure existante')
        expect(page).to have_content(siret)
        expect(page).to have_content('Ma structure existante')

        compte_pro_connect.reload
        expect(compte_pro_connect.siret_pro_connect).to eq(siret)
        expect(compte_pro_connect.etape_inscription).to eq('assignation_structure')

        click_on 'Rejoindre'

        compte_pro_connect.reload
        expect(compte_pro_connect.structure).to eq(structure_existante)
      end
    end

    context 'avec un SIRET ne correspondant à aucune structure' do
      before do
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
              "nom_complet" => "Entreprise Test",
              "activite_principale" => "6201Z",
              "complements" => {
                "liste_idcc" => []
              }
            } ]
          }
        )
        # rubocop:enable RSpec/AnyInstance

        # Mock MiseAJourSiret pour définir raison_sociale et adresse
        allow(MiseAJourSiret).to receive(:new) do |structure|
          mise_a_jour = instance_double(MiseAJourSiret)
          allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
            structure.statut_siret = true
            structure.date_verification_siret = Time.current
            structure.code_naf = "6201Z"
            structure.idcc = []
            structure.raison_sociale = "Entreprise Test"
            structure.adresse = "1 rue de la Paix, 75001 Paris"
            true
          end
          mise_a_jour
        end
visit inscription_recherche_structure_path
      end


      it 'crée une structure temporaire et redirige vers la création' do
        fill_in 'siret', with: siret
        click_on 'Valider'

        expect(page).to have_current_path(inscription_structure_path)

        # La structure est sauvegardée lors de l'assignation au compte,
        # donc elle est considérée comme existante
        expect(page).to have_content('Création de votre structure')
        expect(page).to have_content(siret)
        expect(page).to have_content('Entreprise Test')

        compte_pro_connect.reload
        expect(compte_pro_connect.etape_inscription).to eq('assignation_structure')
      end
    end

    context 'bouton Retour' do
      before do
        visit inscription_recherche_structure_path
      end

      it 'permet de revenir à l\'étape précédente' do
        click_on 'Retour'

        expect(page).to have_current_path(inscription_informations_compte_path)
      end
    end

    context 'lien vers l\'Annuaire des Entreprises' do
      before do
        visit inscription_recherche_structure_path
      end

      it 'ouvre le lien dans une nouvelle fenêtre' do
        lien = find_link('Retrouver votre SIRET sur l\'Annuaire des Entreprises')
        expect(lien[:target]).to eq('_blank')
        expect(lien[:rel]).to eq('noopener noreferrer')
        expect(lien[:href]).to include('annuaire-entreprises.data.gouv.fr')
        expect(lien[:href]).to include('mtm_campaign=proconnect')
      end
    end
  end
end
