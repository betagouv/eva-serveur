require 'rails_helper'

describe 'Admin::EvaluationsEvaproController#destroy', type: :request do
  let(:mon_compte) { create :compte, role: 'superadmin' }
  let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
  let(:evaluation_evapro) do
    EvaluationEvapro.create!(campagne: campagne_evapro,
                             beneficiaire: create(:beneficiaire),
                             debutee_le: 1.hour.ago)
  end

  before do
    Bullet.enable = false
    sign_in mon_compte
  end

  after { Bullet.enable = true }

  context "quand le referer contient un filtre (query string)" do
    let(:referer) { admin_evaluations_evapro_path(q: { debutee_le_gteq: "2024-01-01" }) }

    it "retourne sur le referer plutôt que sur la liste non filtrée" do
      delete admin_evaluation_evapro_path(evaluation_evapro), headers: { "HTTP_REFERER" => referer }

      expect(evaluation_evapro.reload.deleted?).to be true
      expect(response).to redirect_to(referer)
    end
  end

  context "quand le referer est la page du bénéficiaire" do
    let(:referer) { admin_beneficiaire_path(evaluation_evapro.beneficiaire) }

    it "retourne sur la page du bénéficiaire" do
      delete admin_evaluation_evapro_path(evaluation_evapro), headers: { "HTTP_REFERER" => referer }

      expect(evaluation_evapro.reload.deleted?).to be true
      expect(response).to redirect_to(referer)
    end
  end

  context "sans filtre ni page bénéficiaire dans le referer" do
    it "retourne sur la liste des évaluations Eva Pro" do
      delete admin_evaluation_evapro_path(evaluation_evapro)

      expect(evaluation_evapro.reload.deleted?).to be true
      expect(response).to redirect_to(admin_evaluations_evapro_path)
    end
  end
end
