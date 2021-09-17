# frozen_string_literal: true

require 'rails_helper'

describe 'API Collections Evenements', type: :request do
  describe 'POST /evaluations/:id/collections_evenements' do
    context 'avec une évaluation inexistante' do
      before { post '/api/evaluations/id_inconnu/collections_evenements' }

      it do
        expect(response).to have_http_status(404)
      end
    end

    context 'avec une évaluation existante' do
      let!(:situation_inventaire) { create :situation_inventaire }
      let(:evaluation) { create :evaluation }
      let(:donnees_evenements) do
        {
          evenements: [
            {
              date: 1_631_719_609_975,
              donnees: {},
              nom: 'demarrage',
              position: 0,
              session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
              situation: situation_inventaire.nom_technique
            }
          ]
        }
      end

      before do
        post "/api/evaluations/#{evaluation.id}/collections_evenements", params: donnees_evenements
      end

      it do
        expect(response).to have_http_status(201)
      end
    end
  end
end
