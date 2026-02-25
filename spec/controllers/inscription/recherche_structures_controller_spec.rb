require 'rails_helper'

describe Inscription::RechercheStructuresController, type: :controller do
  render_views

  let(:compte) {
 create(:compte_pro_connect, etape_inscription: 'recherche_structure', structure: nil) }

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

    context "quand le compte n'est pas en étape recherche_structure" do
      let(:compte) { create(:compte_pro_connect, etape_inscription: 'complet') }

      it 'redirige vers le dashboard' do
        patch :update, params: { siret: siret }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context 'avec un SIRET valide et structure existante' do
      let!(:structure) { create(:structure_locale, siret: siret) }

      it 'assigne la structure au compte et redirige' do
        patch :update, params: { siret: siret }
        compte.reload
        expect(compte.structure).to be_nil
        expect(compte.etape_inscription).to eq('assignation_structure')
        expect(response).to redirect_to(inscription_structure_path)
      end
    end

    context 'avec un SIRET valide et structure non existante' do
      before do
        # Mock de l'API Sirene pour que MiseAJourSiret fonctionne correctement
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
        # rubocop:disable RSpec/AnyInstance
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
        # rubocop:enable RSpec/AnyInstance
      end

      it 'crée une structure temporaire et redirige' do
        patch :update, params: { siret: siret }
        compte.reload
        expect(compte.etape_inscription).to eq('assignation_structure')
        expect(response).to redirect_to(inscription_structure_path)
      end
    end

    context "avec un SIRET déclaré fermé par l'API" do
      let(:siret_ferme) { "45132137600035" }

      before do
        allow(MiseAJourSiret).to receive(:new) do |structure|
          mise_a_jour = instance_double(MiseAJourSiret)
          allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
            structure.statut_siret = false
            structure.siret_ferme = true
            false
          end
          mise_a_jour
        end
      end

      it "reste sur la page et affiche le message d'erreur spécifique SIRET fermé" do
        patch :update, params: { compte: { siret_pro_connect: siret_ferme } }
        expect(response).to have_http_status(:success)
        expect(response).not_to redirect_to(inscription_structure_path)
        message = I18n.t(
          "activerecord.errors.models.compte.attributes.siret_pro_connect.siret_ferme"
        )
        expect(response.body).to include(message)
      end
    end

    context 'avec un SIRET invalide (format)' do
      it 'reste sur la page et affiche une erreur sur le champ sans flash structure non trouvée' do
        patch :update, params: { compte: { siret_pro_connect: "123" } }
        expect(response).to have_http_status(:success)
        expect(response).not_to redirect_to(inscription_structure_path)
        expect(flash[:error]).to be_blank
        expect(response.body).to include("fr-message--error")
        expect(response.body).to include("SIRET invalide.")
      end
    end

    context 'avec un SIRET vide' do
      it 'reste sur la page et affiche une erreur sur le champ' do
        patch :update, params: { compte: { siret_pro_connect: "" } }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("fr-message--error")
      end
    end
  end
end
