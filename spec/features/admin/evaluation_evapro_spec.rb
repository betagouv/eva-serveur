require 'rails_helper'

describe 'Admin - EvaluationEvapro', type: :feature do
  before { connecte(mon_compte)  }

  let(:role) { 'superadmin' }
  let(:mon_compte) { create :compte, role: role }
  let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
  let(:evaluation_evapro) do
    EvaluationEvapro.create!(campagne: campagne_evapro,
                             beneficiaire: create(:beneficiaire),
                             debutee_le: 1.hour.ago)
  end


  describe 'suppression' do
    before do
      Bullet.enable = false
      visit admin_evaluation_evapro_path(evaluation_evapro)
    end

    after { Bullet.enable = true }

    it "supprime l'évaluation et retourne sur la liste des évaluations Eva Pro" do
      url_suppression = admin_evaluation_evapro_path(evaluation_evapro)
      find("#action_items_sidebar_section a[href='#{url_suppression}']").click

      expect(evaluation_evapro.reload.deleted?).to be true
      expect(page.current_url).to eql(admin_evaluations_evapro_url)
    end
  end
end
