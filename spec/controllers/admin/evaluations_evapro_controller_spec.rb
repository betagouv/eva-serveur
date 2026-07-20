require "rails_helper"

describe Admin::EvaluationsEvaproController, type: :controller do
  describe "GET #index avec un compte OPCO restreint" do
    let(:structure) { create(:structure_opco, :avec_admin) }
    let(:compte_connecte) { create(:compte_conseiller, :acceptee, structure: structure) }

    before { sign_in compte_connecte }

    it "refuse l'accès à la page des évaluations evapro" do
      get :index

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET #index" do
    let(:structure) do
      create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO)
    end
    let(:compte_connecte) { create(:compte_admin, structure: structure) }
    let(:campagne) { create(:campagne, compte: compte_connecte) }
    let!(:evaluation) { create(:evaluation, :evapro, campagne: campagne) }

    before { sign_in compte_connecte }

    it "répond avec succès et charge les parties en une requête pour la page" do
      partie_queries = []
      callback = lambda do |_name, _start, _finish, _id, payload|
        partie_queries << payload[:sql] if payload[:name] == "Partie Load"
      end
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        get :index
      end

      expect(response).to have_http_status(:ok)
      expect(partie_queries.size).to be <= 2
    end
  end

  describe "suppression" do
    let(:structure) do
      create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO)
    end
    let!(:compte_connecte) { create :compte_admin, structure: structure }
    let(:campagne) { create :campagne, compte: compte_connecte }
    let!(:evaluation) { create :evaluation, :evapro, campagne: campagne }

    before { sign_in compte_connecte }

    it "redirige vers la liste des évaluations avec les filtres préservés" do
      referer = admin_evaluations_evapro_path(q: { campagne_id_eq: campagne.id })
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(referer)
    end

    it "redirige vers la liste des évaluations depuis la page show" do
      referer = admin_evaluation_evapro_path(evaluation)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(admin_evaluations_evapro_path)
    end

    it "redirige vers la page du bénéficiaire depuis sa fiche" do
      beneficiaire = evaluation.beneficiaire
      referer = admin_beneficiaire_path(beneficiaire)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(referer)
    end
  end
end
