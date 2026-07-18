require "rails_helper"

describe Admin::EvaluationsEvaController, type: :controller do
  describe "GET #index avec un compte OPCO restreint" do
    let(:structure) { create(:structure_opco, :avec_admin) }
    let(:compte_connecte) { create(:compte_conseiller, :acceptee, structure: structure) }

    before { sign_in compte_connecte }

    it "refuse l'accès à la page des évaluations eva" do
      get :index

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "suppression" do
    let(:structure) { create :structure_locale }
    let!(:compte_connecte) { create :compte_admin, structure: structure }
    let(:campagne) { create :campagne, compte: compte_connecte }
    let!(:evaluation) { create :evaluation, :eva, campagne: campagne }

    before { sign_in compte_connecte }

    it "redirige vers la liste des évaluations avec les filtres préservés" do
      referer = admin_evaluations_eva_path(q: { campagne_id_eq: campagne.id })
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(referer)
    end

    it "redirige vers la liste des évaluations depuis la page show" do
      referer = admin_evaluation_eva_path(evaluation)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(admin_evaluations_eva_path)
    end

    it "redirige vers la page du bénéficiaire depuis sa fiche" do
      beneficiaire = evaluation.beneficiaire
      referer = admin_beneficiaire_path(beneficiaire)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(referer)
    end
  end

  describe 'xls' do
    let!(:compte) { create :compte_superadmin }

    before do
      sign_in compte
      create_list :evaluation, 31
      get :index, format: :xls
    end

    it 'renvoie un export excel' do
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include 'excel'
    end
  end
end
