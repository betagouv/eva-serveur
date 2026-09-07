require 'rails_helper'

describe 'Admin::PdfGenerationsController', type: :request do
  let(:mon_compte) { create(:compte) }

  describe 'GET /admin/pdf_generations/:id' do
    it "affiche la page d'attente quand le jeton correspond au compte connecté" do
      sign_in mon_compte
      token = Pdf::GenerationToken.genere(mon_compte.id)

      get admin_pdf_generation_path(token)

      expect(response).to have_http_status(:ok)
    end

    it "redirige vers le dashboard quand le jeton appartient à un autre compte" do
      autre_compte = create(:compte)
      sign_in mon_compte
      token = Pdf::GenerationToken.genere(autre_compte.id)

      get admin_pdf_generation_path(token)

      expect(response).to redirect_to(admin_dashboard_path)
    end

    it 'redirige vers le dashboard pour un jeton invalide' do
      sign_in mon_compte

      get admin_pdf_generation_path('jeton-invalide')

      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
