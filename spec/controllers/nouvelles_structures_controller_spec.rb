require "rails_helper"

describe NouvellesStructuresController, type: :controller do
  let(:compte_params) do
    {
      nom: "John",
      prenom: "Doe",
      email: "john@example.com",
      password: "password123",
      password_confirmation: "password123",
      structure_attributes: {
        nom: "Ma Structure",
        code_postal: "75001",
        siret: "12345678901234",
        type_structure: "entreprise",
        usage: "Eva: entreprises",
        idcc: [ "3", "18" ]
      }
    }
  end

  describe "POST #create" do
    before do
      # Mock recaptcha pour tous les tests
      allow(controller).to receive(:verify_recaptcha).and_return(true)
    end

    context "avec des paramètres valides" do
      it "crée un compte et une structure" do
        expect do
          post :create, params: { compte: compte_params }
        end.to change(Compte, :count).by(1)
          .and change(Structure, :count).by(1)
      end

      it "appelle le service d'affiliation OPCO" do
        service_double = instance_double(AffiliationOpcoService)
        allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:affilie_opcos)

        post :create, params: { compte: compte_params }

        expect(service_double).to have_received(:affilie_opcos)
      end

      it "redirige vers le dashboard admin" do
        post :create, params: { compte: compte_params }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "avec des paramètres invalides" do
      let(:compte_params_invalides) do
        compte_params.merge(email: "")
      end

      it "ne crée pas de compte" do
        expect do
          post :create, params: { compte: compte_params_invalides }
        end.not_to change(Compte, :count)
      end

      it "rend le template show" do
        post :create, params: { compte: compte_params_invalides }
        expect(response).to have_http_status(:success)
        expect(response).not_to redirect_to(admin_dashboard_path)
      end
    end
  end
end
