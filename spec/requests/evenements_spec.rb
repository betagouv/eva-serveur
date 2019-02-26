# frozen_string_literal: true

require 'rails_helper'

describe 'Evenement API', type: :request do
  describe 'POST /evenements' do
    let(:payload) do
      {
        "evenement": {
          "date": '2019-02-26T09:42:47.186Z',
          "type_evenement": 'ouvertureContent',
          "description": 'coucou'
        }
      }
    end

    context 'Quand une requête est valide' do
      before { post '/api/evenements', params: payload }

      it 'Crée un événement' do
        expect(Evenement.count).to eq 1
      end

      it 'retourne une 200' do
        expect(response).to have_http_status(201)
      end
    end
  end
end
