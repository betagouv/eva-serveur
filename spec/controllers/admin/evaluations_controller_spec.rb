require "rails_helper"

describe Admin::EvaluationsController, type: :controller do
  describe "GET #index en tant qu'utilisateur entreprise (Eva Pro)" do
    let(:structure) do
      create(:structure_locale,
             type_structure: "entreprise",
             usage: AvecUsage::USAGE_ENTREPRISES)
    end
    let(:compte_connecte) { create(:compte_admin, structure: structure) }
    let(:campagne) { create(:campagne, compte: compte_connecte) }
    let!(:evaluation) { create(:evaluation, campagne: campagne) }

    before { sign_in compte_connecte }

    it "n'appelle pas FabriqueRestitution.restitution_globale " \
       "(donnees lues depuis Partie.synthese)" do
      allow(FabriqueRestitution).to receive(:restitution_globale)

      get :index

      expect(FabriqueRestitution).not_to have_received(:restitution_globale)
    end

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
    let(:structure) { create :structure_locale }
    let!(:compte_connecte) { create :compte_admin, structure: structure }
    let(:campagne) { create :campagne, compte: compte_connecte }
    let!(:evaluation) { create :evaluation, campagne: campagne }

    before { sign_in compte_connecte }

    it "redirige vers la liste des évaluations avec les filtres préservés" do
      referer = admin_evaluations_path(q: { campagne_id_eq: campagne.id })
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(referer)
    end

    it "redirige vers la liste des évaluations depuis la page show" do
      referer = admin_evaluation_path(evaluation)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: evaluation.id }

      expect(response).to redirect_to(admin_evaluations_path)
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
