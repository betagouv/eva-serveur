# frozen_string_literal: true

require 'rails_helper'

describe 'Evenement API', type: :request do
  describe 'POST /evenements' do
    let(:chemin) { "#{Rails.root}/spec/support/evenement/donnees.json" }
    let(:donnees) { JSON.parse(File.read(chemin)) }
    let!(:situation_inventaire) { create :situation_inventaire, nom_technique: 'inventaire' }

    let(:payload_valide) do
      {
        "date": 1_551_111_089_238,
        "nom": 'ouvertureContenant',
        "donnees": donnees,
        "situation": 'inventaire',
        "session_id": 'O8j78U2xcb2'
      }
    end

    let(:payload_invalide) do
      {
        "date": nil,
        "nom": 'ouvertureContenant',
        "situation": 'inventaire',
        "session_id": 'O8j78U2xcb2',
        "donnees": donnees
      }
    end

    context 'Quand une requête est valide' do
      it 'Crée un événement et le relie à sa situation' do
        expect { post '/api/evenements', params: payload_valide }
          .to change { Evenement.count }.by(1)
        evenement = Evenement.last
        expect(evenement.date).to eq DateTime.new(2019, 0o2, 25, 16, 11, 29)
        expect(evenement.situation).to eq situation_inventaire
      end

      it 'retourne une 201' do
        post '/api/evenements', params: payload_valide
        expect(response).to have_http_status(201)
      end
    end

    context 'Quand une requête est invalide' do
      before { post '/api/evenements', params: payload_invalide }

      it 'retourne une 422' do
        expect(response.body).to eq '["Date doit être rempli(e)"]'
        expect(response).to have_http_status(422)
      end
    end
  end
end
