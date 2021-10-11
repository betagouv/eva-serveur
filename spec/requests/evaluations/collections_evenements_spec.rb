# frozen_string_literal: true

require 'rails_helper'

describe 'API Collections Evenements', type: :request do
  describe 'POST /evaluations/:id/collections_evenements' do
    let!(:situation_inventaire) { create :situation_inventaire }
    let!(:situation_livraison) { create :situation_livraison }
    let(:evenement1) do
      {
        date: 1_631_719_609_975,
        donnees: {},
        nom: 'demarrage',
        position: 0,
        session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
        situation: situation_inventaire.nom_technique
      }
    end
    let(:evenement2) do
      {
        date: 1_631_891_672_641,
        donnees: { contenant: '16' },
        nom: 'ouvertureContenant',
        position: 1,
        session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
        situation: situation_inventaire.nom_technique
      }
    end
    let(:evenement3) do
      {
        date: 1_631_891_703_815,
        donnees: {},
        nom: 'finSituation',
        position: 0,
        session_id: '184e1079-3bb9-4229-921e-4c2574d94934',
        situation: situation_livraison.nom_technique
      }
    end
    let(:donnees_evenements) do
      { evenements: [evenement1, evenement2, evenement3] }
    end

    context 'avec une évaluation inexistante' do
      it do
        post '/api/evaluations/evaluation_inconnue/collections_evenements',
             params: donnees_evenements
        expect(response).to have_http_status(422)
      end
    end

    context 'avec une évaluation existante' do
      let(:evaluation) { create :evaluation }

      it do
        post "/api/evaluations/#{evaluation.id}/collections_evenements",
             params: donnees_evenements
        expect(response).to have_http_status(201)
      end
    end
  end
end
