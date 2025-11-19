require 'rails_helper'

describe 'API Collections Evenements', type: :request do
  describe 'POST /evaluations/:id/collections_evenements' do
    let!(:situation_inventaire) { create :situation_inventaire }
    let!(:situation_livraison) { create :situation_livraison }
    let(:evenement1) do
      {
        date: 1_631_719_609_975,
        nom: 'demarrage',
        position: 0,
        session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
        situation: situation_inventaire.nom_technique
      }
    end
    let(:evenement2) do
      {
        date: 1_631_891_672_641,
        nom: 'ouvertureContenant',
        position: 1,
        session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
        situation: situation_inventaire.nom_technique,
        donnees: { contenant: '16' }
      }
    end
    let(:evenement3) do
      {
        date: 1_631_891_703_815,
        nom: 'finSituation',
        position: 2,
        session_id: 'abbd368d-dc2d-49a4-ae8a-face8fefbc90',
        situation: situation_livraison.nom_technique
      }
    end
    let(:donnees_evenements) do
      { evenements: [ evenement1, evenement2, evenement3 ] }
    end
    let(:donnees_evenements_transmises) do
      donnees_evenements[:evenements].map(&:to_json).map { |s| JSON.parse(s) }.map do |e|
        e.transform_values { |value| value.is_a?(Hash) ? value : value.to_s }
      end
    end

    context 'avec une évaluation inexistante' do
      it do
        post '/api/evaluations/evaluation_inconnue/collections_evenements',
             params: donnees_evenements
        expect(response.body).to eq '{"message":"Évaluation non trouvée"}'
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'avec une évaluation existante' do
      let(:evaluation) { create :evaluation }

      it do
        expect do
          post "/api/evaluations/#{evaluation.id}/collections_evenements",
               params: donnees_evenements
        end
          .to have_enqueued_job(PersisteCollectionEvenementsJob)
          .with(evaluation.id, donnees_evenements_transmises)
          .exactly(1)
        expect(response).to have_http_status(:created)
      end
    end
  end
end
