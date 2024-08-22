# frozen_string_literal: true

require 'rails_helper'

describe 'Questionnaires API', type: :request do
  describe 'GET /questionnaires/:id' do
    let(:question1) { create :question_saisie, transcription_ecrit: 'Ma question 1' }
    let(:question2) { create :question_qcm }
    let(:question3) { create :question_saisie, transcription_ecrit: 'Ma question 3' }
    let(:question4) { create :question_qcm }

    let(:questionnaire) do
      create :questionnaire, questions: [question1, question2, question3, question4]
    end

    it 'retourne les questions' do
      get "/api/questionnaires/#{questionnaire.id}"

      expect(response).to be_ok
      expect(response.parsed_body.size).to be(4)
    end

    it "retourne une 404 lorsque le questionnaire n'existe pas" do
      get '/api/questionnaires/404'

      expect(response).to have_http_status(:not_found)
    end
  end
end
