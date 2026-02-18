require 'rails_helper'

describe Admin::EvaluationsController, type: :controller do
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
