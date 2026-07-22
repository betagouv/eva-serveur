require 'rails_helper'

describe 'Admin::EvaluationsController', type: :request do
  before { Bullet.enable = false }
  after { Bullet.enable = true }

  describe 'GET /admin/evaluations' do
    context "quand l'utilisateur est evapro" do
      let(:structure_evapro) { create(:structure_locale, :eva_pro) }
      let(:mon_compte) { create(:compte, structure: structure_evapro) }

      it "redirige vers la liste des évaluations Eva Pro" do
        sign_in mon_compte

        get admin_evaluations_path

        expect(response).to redirect_to(admin_evaluations_evapro_path)
      end
    end

    context "quand l'utilisateur n'est pas evapro" do
      let(:mon_compte) { create(:compte) }

      it "redirige vers la liste des évaluations Eva" do
        sign_in mon_compte

        get admin_evaluations_path

        expect(response).to redirect_to(admin_evaluations_eva_path)
      end
    end
  end

  describe 'GET /admin/evaluations/:id' do
    let(:mon_compte) { create(:compte) }

    context "quand l'évaluation est une évaluation Eva Pro" do
      let(:evaluation_evapro) { create(:evaluation, :evapro) }

      it "redirige vers la page de l'évaluation Eva Pro" do
        sign_in mon_compte

        get admin_evaluation_path(evaluation_evapro)

        expect(response).to redirect_to(admin_evaluation_evapro_path(evaluation_evapro))
      end
    end

    context "quand l'évaluation est une évaluation Eva" do
      let(:evaluation_eva) { create(:evaluation, :eva) }

      it "redirige vers la page de l'évaluation Eva" do
        sign_in mon_compte

        get admin_evaluation_path(evaluation_eva)

        expect(response).to redirect_to(admin_evaluation_eva_path(evaluation_eva))
      end
    end
  end
end
