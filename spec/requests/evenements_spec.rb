# frozen_string_literal: true

require 'rails_helper'

describe 'Evenement API', type: :request do
  describe 'POST /evenements' do
    let(:payload) do
      {
        "evenement": {
          "date": 1_551_111_089_238,
          "type_evenement": 'ouvertureContent',
          "description": 'coucou'
        }
      }
    end

    context 'Quand une requête est valide' do
      before { post '/api/evenements', params: payload }

      it 'Crée un événement' do
        expect(Evenement.count).to eq 1
        expect(Evenement.last.date).to eq DateTime.new(2019, 0o2, 25, 16, 11, 29)
      end

      it 'retourne une 200' do
        expect(response).to have_http_status(201)
      end
    end
  end
end
