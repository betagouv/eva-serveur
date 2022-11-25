# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation API', type: :request do
  describe 'POST /evaluations' do
    let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

    context 'Création quand une requête est valide' do
      let(:date) { Time.zone.local(2021, 10, 4) }
      let(:unUserAgent) do
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:104.0) Gecko/20100101 Firefox/104.0'
      end
      let(:payload_valide_avec_campagne) do
        {
          nom: 'Roger',
          code_campagne: 'ETE19',
          debutee_le: date.iso8601,
          conditions_passation_attributes: {
            user_agent: unUserAgent,
            hauteur_fenetre_navigation: 10,
            largeur_fenetre_navigation: 20
          },
          donnee_sociodemographique_attributes: {
            age: 18,
            genre: 'homme',
            dernier_niveau_etude: 'college',
            derniere_situation: 'scolarisation'
          }
        }
      end

      before do
        post '/api/evaluations', params: payload_valide_avec_campagne
        @donnee_sociodemographique = DonneeSociodemographique.last
      end

      it do
        evaluation = Evaluation.last
        expect(evaluation.campagne).to eq campagne_ete19
        expect(evaluation.nom).to eq 'Roger'
        expect(evaluation.debutee_le).to eq date
        expect(evaluation.beneficiaire.nom).to eq 'Roger'

        expect(response).to have_http_status(:created)
        reponse = JSON.parse(response.body)
        expect(reponse['id']).to eq evaluation.id
      end

      it do
        expect(ConditionsPassation.count).to eq 1
        expect(ConditionsPassation.last.user_agent).to eq unUserAgent
        expect(ConditionsPassation.last.materiel_utilise).to eq 'desktop'
        expect(ConditionsPassation.last.modele_materiel).to eq nil
        expect(ConditionsPassation.last.nom_navigateur).to eq 'Firefox'
        expect(ConditionsPassation.last.version_navigateur).to eq '104.0'
        expect(ConditionsPassation.last.hauteur_fenetre_navigation).to eq 10
        expect(ConditionsPassation.last.largeur_fenetre_navigation).to eq 20
      end

      it { expect(@donnee_sociodemographique.age).to eq 18 }
      it { expect(@donnee_sociodemographique.genre).to eq 'homme' }
      it { expect(@donnee_sociodemographique.dernier_niveau_etude).to eq 'college' }
      it { expect(@donnee_sociodemographique.derniere_situation).to eq 'scolarisation' }
    end

    context 'Quand le code campagne est inconnu' do
      let(:payload_invalide) { { nom: '', code_campagne: 'ETE190' } }

      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq %w[campagne code_campagne debutee_le nom]
        expect(json.values.sort).to eq [['Code inconnu'], ['doit être présente'],
                                        ['doit être rempli'], ['doit être rempli(e)']]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'Quand une requête est invalide' do
      let(:payload_invalide) { { nom: '', code_campagne: '' } }

      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq %w[campagne debutee_le nom]
        expect(json.values.sort).to eq [['doit être présente'], ['doit être rempli'],
                                        ['doit être rempli(e)']]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'Quand une requête est vide' do
      let(:payload_invalide) { {} }

      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq %w[beneficiaire campagne debutee_le nom]
        expect(json.values.sort).to eq [['doit exister'], ['doit être présente'],
                                        ['doit être rempli'], ['doit être rempli(e)']]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /evaluations/:id' do
    let!(:evaluation) { create :evaluation, email: 'monemail@eva.fr', nom: 'James' }

    context 'Quand une requête est invalide pour un enum de données sociodémographiques' do
      let(:params) do
        {
          donnee_sociodemographique_attributes: {
            dernier_niveau_etude: 'invalide'
          }
        }
      end

      it 'retourne une 500 (comportement par défaut des enums Rails)' do
        expect do
          patch "/api/evaluations/#{evaluation.id}", params: params
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'PATCH /evaluations/:id' do
    let!(:evaluation) { create :evaluation, email: 'monemail@eva.fr', nom: 'James' }

    before { patch "/api/evaluations/#{evaluation.id}", params: params }

    context 'Met à jour email et téléphone avec une requête valide' do
      let(:date) { Time.zone.local(2021, 10, 4) }
      let(:params) do
        { email: 'coucou-a-jour@eva.fr', telephone: '01 02 03 04 05', terminee_le: date.iso8601 }
      end

      it do
        evaluation.reload
        expect(evaluation.terminee_le).to eq date
        expect(response).to have_http_status(:ok)
      end
    end

    context 'requête invalide' do
      let(:params) { { nom: '' } }

      it do
        expect(evaluation.reload.nom).to eq 'James'
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
