# frozen_string_literal: true

require 'rails_helper'

describe 'Admin Beneficiaires Batch Action', type: :request do
  let!(:mon_compte) { create :compte_superadmin }
  let(:parcours_type) { create :parcours_type, :competences_de_base }
  let(:campagne) do
    create :campagne, compte: mon_compte, libelle: 'Paris 2019', code: 'PARIS2019',
                      parcours_type: parcours_type
  end
  let!(:beneficiaire1) { create :beneficiaire }
  let!(:evaluation1) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire1 }

  before do
    sign_in mon_compte
  end

  describe "POST batch_action fusionner" do
    let!(:beneficiaire2) { create :beneficiaire }
    let!(:evaluation2) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire2 }

    it "lie les bénéficiaires sélectionnés" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'fusionner',
        collection_selection: [ beneficiaire1.id, beneficiaire2.id ]
      }

      expect(beneficiaire1.reload.evaluations).to contain_exactly(evaluation1, evaluation2)
      expect(beneficiaire2.reload.deleted_at).not_to be_nil
      expect(response).to redirect_to("/admin/beneficiaires/#{beneficiaire1.id}")
    end
  end
end
