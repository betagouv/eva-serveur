# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation API', type: :request do
  describe 'POST /evaluations' do
    let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

    context 'Quand une requête est valide' do
      let(:payload_valide_avec_campagne) { { nom: 'Roger', code_campagne: 'ETE19' } }
      before { post '/api/evaluations', params: payload_valide_avec_campagne }
      it { expect(Evaluation.last.campagne).to eq campagne_ete19 }
    end

    context 'Quand une requête est invalide' do
      let(:payload_invalide) { { nom: '', code_campagne: 'ETE190' } }
      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys).to eq %w[nom campagne]
        expect(response).to have_http_status(422)
      end
    end
  end
end
