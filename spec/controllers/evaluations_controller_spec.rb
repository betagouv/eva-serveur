require 'rails_helper'

describe Admin::EvaluationsController do
  let!(:compte) { create :compte_superadmin }

  describe 'xls' do
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
