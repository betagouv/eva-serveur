require 'rails_helper'

describe 'Evenement API', type: :request do
  describe 'POST /evenements' do
    let(:chemin) { Rails.root.join('spec/support/evenement/donnees.json') }
    let(:donnees) { JSON.parse(File.read(chemin)) }
    let!(:situation_inventaire) { create :situation_inventaire, nom_technique: 'inventaire' }
    let(:evaluation) { create :evaluation }

    let(:payload_valide) do
      {
        date: 1_551_111_089_238,
        nom: 'ouvertureContenant',
        donnees: donnees,
        situation: situation_inventaire.nom_technique,
        position: 58,
        session_id: 'O8j78U2xcb2',
        evaluation_id: evaluation.id
      }
    end

    let(:payload_invalide) do
      {
        date: nil,
        nom: 'ouvertureContenant',
        situation: situation_inventaire.nom_technique,
        session_id: 'O8j78U2xcb2',
        donnees: donnees,
        evaluation_id: evaluation.id
      }
    end

    context 'quand une requête est valide' do
      it 'Crée un événement et une partie' do
        post '/api/evenements', params: payload_valide

        expect(response).to have_http_status(:created)
        evenement = Evenement.last
        expect(evenement.date.to_datetime).to eq Time.zone.at(1_551_111_089, 238_000).to_datetime
        expect(evenement.position).to eq 58

        partie = Partie.last
        expect(partie.evaluation).to eq evaluation
        expect(partie.situation).to eq situation_inventaire
      end
    end

    context 'quand une requête est invalide' do
      before { post '/api/evenements', params: payload_invalide }

      it 'retourne une 422' do
        expect(response.body).to eq '["Date client doit être rempli(e)"]'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
