# frozen_string_literal: true

require 'rails_helper'

describe 'Questionnaires API', type: :request do
  describe 'GET /questionnaires/:id' do
    let(:question1) { create :question_saisie, intitule: 'Ma question 1' }
    let(:question2) { create :question_saisie, intitule: 'Ma question 2' }
    let(:questionnaire) { create :questionnaire, questions: [question1, question2] }

    it 'retourne les questions' do
      get "/api/questionnaires/#{questionnaire.id}"

      expect(response).to be_ok
      expect(response.parsed_body.size).to be(2)
    end

    it "retourne une 404 lorsque le questionnaire n'existe pas" do
      get '/api/questionnaires/404'

      expect(response).to have_http_status(:not_found)
    end
  end
end
