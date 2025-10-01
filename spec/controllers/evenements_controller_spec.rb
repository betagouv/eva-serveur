require 'rails_helper'

describe Api::EvenementsController, type: :controller do
  describe 'POST create' do
    let(:evaluation) { create :evaluation }
    let(:situation) { create :situation_inventaire }

    context "quand la création de l'évènement échoue" do
      it 'renvoie une erreur unprocessable_entity' do
        params = {
          date: 1_551_111_089_238,
          nom: nil,
          donnees: {},
          situation: situation.nom_technique,
          position: 58,
          session_id: 'O8j78U2xcb2',
          evaluation_id: evaluation.id
        }

        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'quand la recherche de la partie échoue' do
      it "journalise l'erreur mais renvoie OK" do
        params = {
          date: 1_551_111_089_238,
          nom: 'demarrage',
          donnees: {},
          situation: situation.nom_technique,
          position: 58,
          session_id: 'O8j78U2xcb2',
          evaluation_id: nil
        }

        post :create, params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
