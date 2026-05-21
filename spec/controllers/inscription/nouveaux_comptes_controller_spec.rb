require "rails_helper"

describe Inscription::NouveauxComptesController, type: :controller do
  describe "GET show" do
    before { sign_in compte }

    context "avec un compte connecté dont l'inscription est complète" do
      let(:compte) do
        create(:compte_conseiller, :structure_avec_admin, etape_inscription: "complet")
      end

      it "redirige vers le tableau de bord" do
        get :show
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "avec un compte connecté qui doit compléter son inscription" do
      let(:compte) do
         create(:compte_conseiller, :structure_avec_admin, etape_inscription: "preinscription")
      end

      it "ne déclenche pas de double render" do
        expect { get :show }.not_to raise_error
      end

      it "redirige vers l'étape d'inscription en cours" do
        get :show
        expect(response).to redirect_to(inscription_informations_compte_path)
      end
    end
  end
end
