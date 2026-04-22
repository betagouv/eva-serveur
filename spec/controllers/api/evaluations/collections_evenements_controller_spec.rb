require 'rails_helper'

describe Api::Evaluations::CollectionsEvenementsController do
  describe "#create SQL injection protection" do
    it "rejette les tentatives d'injection SQL" do
      injection_payload = "' OR '1'='1"

      post :create, params: {
        evaluation_id: injection_payload
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
