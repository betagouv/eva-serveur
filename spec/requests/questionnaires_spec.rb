# frozen_string_literal: true

require 'rails_helper'

describe 'Questionnaires API', type: :request do
  describe 'GET /questionnaires/:id' do
    let(:question) { create :question_qcm, intitule: 'Ma question' }
    let(:questionnaire) { create :questionnaire, questions: [question] }

    it 'retourne les questions' do
      get "/api/questionnaires/#{questionnaire.id}"

      expect(response).to be_ok
      expect(JSON.parse(response.body).size).to eql(1)
    end

    it "retourne une 404 lorsque le questionnaire n'existe pas" do
      get '/api/questionnaires/404'

      expect(response).to have_http_status(404)
    end
  end
end
