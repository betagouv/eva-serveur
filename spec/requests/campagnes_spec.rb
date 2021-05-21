# frozen_string_literal: true

require 'rails_helper'

describe 'Campagne API', type: :request do
  describe 'GET /campagnes/:code_campagne' do
    let(:question) { create :question_qcm, intitule: 'Ma question' }
    let(:questionnaire) { create :questionnaire, questions: [question] }
    let!(:campagne) { create :campagne, questionnaire: questionnaire, code: 'ete 21' }

    it 'retourne les questions de la campagne' do
      get '/api/campagnes/ete%2021'

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(1)
    end

    it "retourne des questions vide lorsque qu'il n'y a pas de questionnaire" do
      campagne.update(questionnaire: nil)
      get '/api/campagnes/ete%2021'

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(0)
    end

    it "retourne une 404 lorsqu'elle n'existe pas" do
      get '/api/campagnes/404'

      expect(response).to have_http_status(404)
    end

    it 'retourne les situations de la campagne' do
      questionnaire = create :questionnaire
      questionnaire_entrainement = create :questionnaire
      questionnaire_surcharge = create :questionnaire
      situation_controle = create :situation_controle
      situation_inventaire = create :situation_inventaire,
                                    libelle: 'Inventaire',
                                    questionnaire_entrainement: questionnaire_entrainement,
                                    questionnaire: questionnaire

      campagne.situations_configurations.create situation: situation_controle,
                                                position: 2,
                                                questionnaire: questionnaire_surcharge
      campagne.situations_configurations.create situation: situation_inventaire, position: 1
      get '/api/campagnes/ete%2021'

      expect(JSON.parse(response.body)['situations'].size).to eql(2)
      expect(JSON.parse(response.body)['situations'][0]['libelle']).to eql('Inventaire')
      expect(JSON.parse(response.body)['situations'][0]['nom_technique']).to eql('inventaire')
      expect(JSON.parse(response.body)['situations'][0]['id']).to eql(situation_inventaire.id)
      expect(JSON.parse(response.body)['situations'][0]['questionnaire_entrainement_id'])
        .to eql(questionnaire_entrainement.id)
      expect(JSON.parse(response.body)['situations'][0]['questionnaire_id'])
        .to eql(questionnaire.id)
      expect(JSON.parse(response.body)['situations'][1]['questionnaire_id'])
        .to eql(questionnaire_surcharge.id)
    end
  end
end
