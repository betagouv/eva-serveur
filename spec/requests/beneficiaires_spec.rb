# frozen_string_literal: true

require 'rails_helper'

describe 'Beneficiaire API', type: :request do
  describe 'GET /api/beneficiaires/:code_beneficiaire' do
    let!(:beneficiaire) { create :beneficiaire, code_personnel: 'ABC1234' }

    it 'retourne les informations du bénéficiaire' do
      get '/api/beneficiaires/ABC1234'

      expect(response).to be_ok
      resultat = response.parsed_body
      expect(resultat['code_personnel']).to eq('ABC1234')
    end

    context "quand le bénéficiaire n'existe pas" do
      it "retourne une 404" do
        code_inconnu = 'INCONNU'
        get "/api/beneficiaires/#{code_inconnu}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
