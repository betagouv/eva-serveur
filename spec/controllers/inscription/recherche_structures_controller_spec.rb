require 'rails_helper'

describe Inscription::RechercheStructuresController, type: :controller do
  let(:compte) { create(:compte_pro_connect, etape_inscription: 'recherche_structure', structure: nil) }

  before do
    sign_in compte
  end

  describe 'GET show' do
    context 'quand le compte est en étape recherche_structure' do
      it 'affiche le formulaire de recherche' do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context 'quand le compte n\'est pas en étape recherche_structure' do
      let(:compte) { create(:compte_pro_connect, etape_inscription: 'complet') }

      it 'redirige vers le dashboard' do
        get :show
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end
  end

  describe 'PATCH update' do
    let(:siret) { '13002526500013' }

    context 'avec un SIRET valide et structure existante' do
      let!(:structure) { create(:structure_locale, siret: siret) }

      it 'assigne la structure au compte et redirige' do
        patch :update, params: { siret: siret }
        compte.reload
        expect(compte.structure).to eq(structure)
        expect(compte.etape_inscription).to eq('assignation_structure')
        expect(response).to redirect_to(inscription_structure_path)
      end
    end

    context 'avec un SIRET valide et structure non existante' do
      before do
        # Mock de l'API Sirene pour que MiseAJourSiret fonctionne correctement
        allow_any_instance_of(Sirene::Client).to receive(:recherche).and_return(
          {
            "results" => [{
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
            }]
          }
        )

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
      end

      it 'crée une structure temporaire et redirige' do
        patch :update, params: { siret: siret }
        compte.reload
        expect(compte.structure).to be_present
        expect(compte.structure.siret).to eq(siret)
        expect(compte.etape_inscription).to eq('assignation_structure')
        expect(response).to redirect_to(inscription_structure_path)
      end
    end

    context 'avec un SIRET vide' do
      it 'affiche une erreur' do
        patch :update, params: { siret: '' }
        expect(flash[:error]).to be_present
        expect(response).to have_http_status(:success)
      end
    end

    context 'avec un SIRET invalide (moins de 14 chiffres)' do
      it 'affiche une erreur' do
        patch :update, params: { siret: '123456789' }
        expect(flash[:error]).to be_present
        expect(response).to have_http_status(:success)
      end
    end

    context 'avec un SIRET invalide (plus de 14 chiffres)' do
      it 'affiche une erreur' do
        patch :update, params: { siret: '123456789012345' }
        expect(flash[:error]).to be_present
        expect(response).to have_http_status(:success)
      end
    end

    context 'avec un SIRET avec espaces' do
      let!(:structure) { create(:structure_locale, siret: siret) }

      it 'retire les espaces et fonctionne correctement' do
        patch :update, params: { siret: '1300 2526 5000 13' }
        compte.reload
        expect(compte.structure).to eq(structure)
        expect(response).to redirect_to(inscription_structure_path)
      end
    end

    context 'quand la recherche échoue' do
      before do
        allow_any_instance_of(RechercheStructureParSiret).to receive(:call).and_raise(StandardError.new('Erreur API'))
      end

      it 'affiche une erreur générique' do
        patch :update, params: { siret: siret }
        expect(flash[:error]).to be_present
        expect(response).to have_http_status(:success)
      end
    end
  end
end

