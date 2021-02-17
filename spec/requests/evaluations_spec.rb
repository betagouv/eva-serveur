# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation API', type: :request do
  describe 'POST /evaluations' do
    let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

    context 'Quand une requête est valide' do
      let(:payload_valide_avec_campagne) do
        { nom: 'Roger', code_campagne: 'ETE19',
          email: 'coucou@eva.fr', telephone: '01 02 03 04 05' }
      end
      before { post '/api/evaluations', params: payload_valide_avec_campagne }

      it do
        evaluation = Evaluation.last
        expect(evaluation.campagne).to eq campagne_ete19
        expect(evaluation.nom).to eq 'Roger'
        expect(evaluation.email).to eq 'coucou@eva.fr'
        expect(evaluation.telephone).to eq '01 02 03 04 05'
      end
    end

    context 'Quand le code campagne est inconnu' do
      let(:payload_invalide) { { nom: '', code_campagne: 'ETE190' } }
      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys).to eq %w[nom campagne code_campagne]
        expect(json.values).to eq [['doit être rempli'], ['doit être présente'], ['Code inconnu']]
        expect(response).to have_http_status(422)
      end
    end

    context 'Quand une requête est invalide' do
      let(:payload_invalide) { { nom: '', code_campagne: '' } }
      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys).to eq %w[nom campagne]
        expect(json.values).to eq [['doit être rempli'], ['doit être présente']]
        expect(response).to have_http_status(422)
      end
    end

    context 'Quand une requête est vide' do
      let(:payload_invalide) { {} }
      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys).to eq %w[nom campagne]
        expect(json.values).to eq [['doit être rempli'], ['doit être présente']]
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /evaluations/:id' do
    let!(:evaluation) { create :evaluation, email: 'monemail@eva.fr', nom: 'James' }
    before { patch "/api/evaluations/#{evaluation.id}", params: params }

    context 'requête valide' do
      let(:params) { { email: 'coucou-a-jour@eva.fr' } }
      it do
        expect(evaluation.reload.email).to eq 'coucou-a-jour@eva.fr'
        expect(response).to have_http_status(200)
      end
    end

    context 'requête invalide' do
      let(:params) { { nom: '' } }
      it do
        expect(evaluation.reload.nom).to eq 'James'
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
      get "/api/evaluations/#{evaluation.id}"

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

    context 'Compétences fortes' do
      let!(:partie) do
        create :partie, evaluation: evaluation,
                        situation: situation_inventaire
      end
      let!(:situation_inventaire) { create :situation_inventaire, libelle: 'Inventaire' }
      let!(:demarrage) { create :evenement_demarrage, partie: partie }

      before { campagne.situations_configurations.create situation: situation_inventaire }

      context 'avec une évaluation avec des compétences identifiées' do
        let!(:saisie) { create(:evenement_saisie_inventaire, :ok, partie: partie) }
        let!(:fin) { create :evenement_fin_situation, partie: partie }

        context 'avec une campagne configurée sans compétences fortes' do
          before do
            campagne.update(affiche_competences_fortes: false)
            get "/api/evaluations/#{evaluation.id}"
          end

          it { expect(JSON.parse(response.body)['competences_fortes']).to be_empty }
        end

        context 'avec une campagne configurée avec compétences fortes' do
          before { get "/api/evaluations/#{evaluation.id}" }

          it 'retourne les compétences triées par ordre de force décroissante' do
            attendues = [Competence::RAPIDITE, Competence::VIGILANCE_CONTROLE,
                         Competence::ORGANISATION_METHODE].map(&:to_s)
            expect(JSON.parse(response.body)['competences_fortes'].pluck('id'))
              .to eql(attendues)
          end

          it 'envoie aussi le nom et la description des compétences' do
            premiere_competence = JSON.parse(response.body)['competences_fortes'][0]
            expect(premiere_competence['nom']).to eql("Vitesse d'exécution")
            expect(premiere_competence['description'])
              .to eql(I18n.t("#{Competence::RAPIDITE}.description",
                             scope: 'admin.evaluations.restitution_competence'))
            expect(premiere_competence['description']).to_not start_with('translation missing')
          end

          it "envoie aussi l'URL du picto des compétences" do
            premiere_competence = JSON.parse(response.body)['competences_fortes'][0]
            expect(premiere_competence['picto'])
              .to start_with('http://asset_host:port/assets/rapidite')
          end
        end
      end

      context 'avec une évaluation sans compétences identifiées' do
        before { get "/api/evaluations/#{evaluation.id}" }

        it { expect(JSON.parse(response.body)['competences_fortes']).to be_empty }
      end
    end
  end
end
