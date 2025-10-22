require 'rails_helper'

describe 'Evaluation', type: :request do
  let(:unUserAgent) do
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:104.0) Gecko/20100101 Firefox/104.0'
  end

  describe 'API' do
    let(:date) { Time.zone.local(2021, 10, 4) }

    describe 'POST /evaluations' do
      let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

      context 'Création quand une requête est valide' do
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
        let(:payload_invalide) { { nom: 'toto', code_campagne: 'INCONNU' } }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[campagne code_campagne debutee_le]
          expect(json.values.sort).to eq [ [ "Code inconnu" ], [ "doit être présente" ],
                                           [ "doit être rempli(e)" ] ]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'quand le code bénéficiaire est inconnu' do
        let(:payload_invalide) { { code_beneficiaire: '1234567890' } }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys).to include "beneficiaire"
          expect(json.values).to include [ "doit exister" ]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'quand le code bénéficiaire est connu' do
        let(:beneficiaire) { create :beneficiaire }
        let(:payload_valide) do
          {
            code_beneficiaire: beneficiaire.code_beneficiaire,
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

        before { post '/api/evaluations', params: payload_valide }

        it 'retourne une 201' do
          expect(response).to have_http_status(:created)
          expect(Evaluation.last.beneficiaire).to eq beneficiaire
        end
      end

      context 'quand une requête est invalide' do
        let(:payload_invalide) { { nom: '', code_campagne: '' } }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[beneficiaire campagne debutee_le]
          expect(json.values.sort).to eq [ [ 'doit exister' ], [ 'doit être présente' ],
                                           [ 'doit être rempli(e)' ] ]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'quand une requête est vide' do
        let(:payload_invalide) { {} }

        before { post '/api/evaluations', params: payload_invalide }

        it 'retourne une 422' do
          json = response.parsed_body
          expect(json.keys.sort).to eq %w[beneficiaire campagne debutee_le]
          expect(json.values.sort).to eq [ [ 'doit exister' ], [ 'doit être présente' ],
                                           [ 'doit être rempli(e)' ] ]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'PATCH /evaluations/:id' do
      let!(:beneficiaire) { create :beneficiaire, nom: 'Roger' }
      let!(:evaluation) { create :evaluation, beneficiaire: beneficiaire }

      context 'quand une requête est invalide pour un enum de données sociodémographiques' do
        let(:params) do
          {
            donnee_sociodemographique_attributes: {
              dernier_niveau_etude: 'invalide'
            }
          }
        end

        before do
          patch "/api/evaluations/#{evaluation.id}", params: params
        end

        it 'ignore la requette (comportement par défaut Rails)' do
          expect(DonneeSociodemographique.count).to eq 0
        end
      end

      context 'avec de multiple mise à jour' do
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
        it "Met à jour la date de fin avec une requête valide" do
          patch "/api/evaluations/#{evaluation.id}", params: { terminee_le: date.iso8601 }

          evaluation.reload
          expect(evaluation.terminee_le).to eq date
          expect(response).to have_http_status(:ok)
        end

        it "rejete une requête invalide" do
          evaluation.update(debutee_le: date)

          patch "/api/evaluations/#{evaluation.id}", params: { debutee_le: '' }

          expect(evaluation.reload.debutee_le).to eq date
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "Ne permet pas la modification du nom" do
          patch "/api/evaluations/#{evaluation.id}", params: { nom: 'nouveau nom' }

          expect(evaluation.reload.beneficiaire.nom).to eq "Roger"
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'GET /evaluations/:id' do
      let!(:beneficiaire) { create :beneficiaire, nom: 'Roger' }
      let!(:evaluation) { create :evaluation, beneficiaire: beneficiaire }

      before do
        get "/api/evaluations/#{evaluation.id}"
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include evaluation.id.to_s
      end
    end
  end

  describe 'member_action' do
    let(:mon_compte) { create :compte, role: 'admin' }
    let(:ma_campagne) { create :campagne, compte: mon_compte }

    before do
      sign_in mon_compte
    end

    describe "#ajouter_responsable_suivi" do
      let(:mon_collegue) { create :compte_conseiller, structure: mon_compte.structure }
      let(:evaluation) { create :evaluation, campagne: ma_campagne }

      it "peut ajouter un responsable de suivi" do
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
