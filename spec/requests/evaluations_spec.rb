# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation', type: :request do
  let(:unUserAgent) do
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:104.0) Gecko/20100101 Firefox/104.0'
  end

  describe 'API' do
    describe 'POST /evaluations' do
      let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

      context 'Création quand une requête est valide' do
        let(:date) { Time.zone.local(2021, 10, 4) }
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
        end

        it do
          evaluation = Evaluation.last
          expect(evaluation.campagne).to eq campagne_ete19
          expect(evaluation.nom).to eq 'Roger'
          expect(evaluation.debutee_le).to eq date
          expect(evaluation.beneficiaire.nom).to eq 'Roger'

          expect(response).to have_http_status(:created)
          reponse = response.parsed_body
          expect(reponse['id']).to eq evaluation.id
        end

        it do
          expect(ConditionsPassation.count).to eq 1
          conditions_passation = ConditionsPassation.last
          expect(conditions_passation.user_agent).to eq unUserAgent
          expect(conditions_passation.materiel_utilise).to eq 'desktop'
          expect(conditions_passation.modele_materiel).to be_nil
          expect(conditions_passation.nom_navigateur).to eq 'Firefox'
          expect(conditions_passation.version_navigateur).to eq '104.0'
          expect(conditions_passation.hauteur_fenetre_navigation).to eq 10
          expect(conditions_passation.largeur_fenetre_navigation).to eq 20
        end

        it do
          expect(DonneeSociodemographique.count).to eq 1
          donnee_sociodemographique = DonneeSociodemographique.last
          expect(donnee_sociodemographique.age).to eq 18
          expect(donnee_sociodemographique.genre).to eq 'homme'
          expect(donnee_sociodemographique.dernier_niveau_etude).to eq 'college'
          expect(donnee_sociodemographique.derniere_situation).to eq 'scolarisation'
        end
      end

      context 'quand le code campagne est inconnu' do
        let(:payload_invalide) { { nom: '', code_campagne: 'ETE190' } }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[campagne code_campagne debutee_le nom]
          expect(json.values.sort).to eq [['Code inconnu'], ['doit être présente'],
                                          ['doit être rempli'], ['doit être rempli(e)']]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'quand une requête est invalide' do
        let(:payload_invalide) { { nom: '', code_campagne: '' } }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[campagne debutee_le nom]
          expect(json.values.sort).to eq [['doit être présente'], ['doit être rempli'],
                                          ['doit être rempli(e)']]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'quand une requête est vide' do
        let(:payload_invalide) { {} }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[beneficiaire campagne debutee_le nom]
          expect(json.values.sort).to eq [['doit exister'], ['doit être présente'],
                                          ['doit être rempli'], ['doit être rempli(e)']]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'PATCH /evaluations/:id' do
      let!(:evaluation) { create :evaluation, email: 'monemail@eva.fr', nom: 'James' }

      context 'quand une requête est invalide pour un enum de données sociodémographiques' do
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

      context 'avec de multiple mise à jour' do
        let(:date) { Time.zone.local(2021, 10, 4) }
        let(:params) do
          {
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

        let(:params2) do
          {
            conditions_passation_attributes: {
              hauteur_fenetre_navigation: 15
            },
            donnee_sociodemographique_attributes: {
              age: 19
            }
          }
        end

        before do
          patch "/api/evaluations/#{evaluation.id}", params: params
          patch "/api/evaluations/#{evaluation.id}", params: params2
        end

        it do
          expect(ConditionsPassation.count).to eq 1
          expect(ConditionsPassation.last.hauteur_fenetre_navigation).to eq 15
          expect(DonneeSociodemographique.count).to eq 1
          expect(DonneeSociodemographique.last.age).to eq 19
        end
      end

      context 'avec un seul patch' do
        before { patch "/api/evaluations/#{evaluation.id}", params: params }

        context 'Met à jour email et téléphone avec une requête valide' do
          let(:date) { Time.zone.local(2021, 10, 4) }
          let(:params) do
            { email: 'coucou-a-jour@eva.fr',
              telephone: '01 02 03 04 05',
              terminee_le: date.iso8601 }
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
  end

  describe 'member_action' do
    let(:mon_compte) { create :compte, role: 'admin' }
    let(:ma_campagne) { create :campagne, compte: mon_compte }

    before do
      sign_in mon_compte
    end

    describe '#ajouter_responsable_suivi' do
      let(:mon_collegue) { create :compte_admin, structure: mon_compte.structure }
      let(:evaluation) { create :evaluation, campagne: ma_campagne }

      it 'peut ajouter un responsable de suivi' do
        expect do
          post ajouter_responsable_suivi_admin_evaluation_path(evaluation),
               params: { responsable_suivi_id: mon_collegue.id }
        end.to change { evaluation.reload.responsable_suivi }
           .from(nil)
          .to(mon_collegue)
      end

      it "ne fait rien si le responsable de suivi n'existe pas" do
        expect do
          post ajouter_responsable_suivi_admin_evaluation_path(evaluation),
               params: { responsable_suivi_id: nil }
        end.not_to(change { evaluation.reload.responsable_suivi })
      end
    end

    describe '#renseigner_qualification' do
      let(:evaluation) { create :evaluation, :avec_mise_en_action, campagne: ma_campagne }
      let(:remediation) { 'formation_metier' }
      let(:difficulte) { 'aucune_offre_formation' }
      let(:indetermine) { 'indetermine' }

      it 'peut renseigner le dispositif de remédiation' do
        patch renseigner_qualification_admin_evaluation_path(evaluation),
              params: { effectuee: true, qualification: remediation }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be true
        expect(evaluation.mise_en_action.remediation).to eq remediation
      end

      it 'peut ignorer le dispositif de remédiation' do
        patch renseigner_qualification_admin_evaluation_path(evaluation),
              params: { effectuee: true, qualification: indetermine }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be true
        expect(evaluation.mise_en_action.remediation).to eq indetermine
      end

      it 'peut renseigner une difficultée' do
        patch renseigner_qualification_admin_evaluation_path(evaluation),
              params: { effectuee: false, qualification: difficulte }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be false
        expect(evaluation.mise_en_action.difficulte).to eq difficulte
      end

      it 'peut ignorer la difficultée' do
        patch renseigner_qualification_admin_evaluation_path(evaluation),
              params: { effectuee: false, qualification: indetermine }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be false
        expect(evaluation.mise_en_action.difficulte).to eq indetermine
      end
    end
  end
end
