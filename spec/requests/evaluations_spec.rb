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

  describe 'GET /evaluations/:id' do
    let(:question) { create :question_qcm, intitule: 'Ma question' }
    let(:questionnaire) { create :questionnaire, questions: [question] }
    let(:campagne) { create :campagne, questionnaire: questionnaire }
    let(:evaluation) { create :evaluation, campagne: campagne }

    it 'retourne les questions de la campagne' do
      get "/api/evaluations/#{evaluation.id}"

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(1)
    end

    it "retourne des questions vide lorsque qu'il n'y a pas de questionnaire" do
      campagne.update(questionnaire: nil)
      get "/api/evaluations/#{evaluation.id}"

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(0)
    end

    it "retourne une 404 lorsqu'elle n'existe pas" do
      get '/api/evaluations/404'

      expect(response).to have_http_status(404)
    end

    it 'retourne les situations de la campagne' do
      situation_inventaire = create :situation_inventaire, libelle: 'Inventaire'
      campagne.situations << situation_inventaire
      get "/api/evaluations/#{evaluation.id}"
      expect(JSON.parse(response.body)['situations'].size).to eql(1)
      expect(JSON.parse(response.body)['situations'][0]['libelle']).to eql('Inventaire')
    end
  end
end
