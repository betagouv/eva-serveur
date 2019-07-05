# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation API', type: :request do
  describe 'POST /evaluations' do
    context 'Quand une requête est valide' do
      let(:payload_valide) { { nom: 'Roger' } }

      it 'Crée une évaluation' do
        expect { post '/api/evaluations', params: payload_valide }
          .to change { Evaluation.count }.by(1)
      end

      it 'retourne une 201' do
        post '/api/evaluations', params: payload_valide
        expect(response).to have_http_status(201)
      end
    end

    context 'Quand une requête est invalide' do
      let(:payload_invalide) { { nom: '' } }

      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        expect(response.body).to eq '["Nom doit être rempli(e)"]'
        expect(response).to have_http_status(422)
      end
    end
  end
end
