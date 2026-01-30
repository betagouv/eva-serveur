require 'rails_helper'

describe 'Campagne request', type: :request do
  describe 'member_action' do
    let(:mon_compte) { create :compte_admin }
    let(:ma_campagne_prive) { create :campagne, compte: mon_compte, privee: true }

    before do
      sign_in mon_compte
    end

    describe "#autoriser_compte" do
      let(:compte) { create :compte_conseiller, structure: mon_compte.structure }

      it "peut autoriser un compte" do
        expect do
          post autoriser_compte_admin_campagne_path(ma_campagne_prive),
               params: { compte_id: compte.id }
        end.to change { ma_campagne_prive.reload.campagne_compte_autorisations.count }
           .from(0)
           .to(1)

        expect(ma_campagne_prive.campagne_compte_autorisations.last.compte).to eq(compte)
      end

      it "ne fait rien si le compte n'existe pas" do
        expect do
          post autoriser_compte_admin_campagne_path(ma_campagne_prive),
               params: { compte_id: "identifiant-inconnu" }
        end.not_to(change { ma_campagne_prive.reload.campagne_compte_autorisations.count })
      end
    end
  end

  describe 'API' do
    describe 'GET /api/campagnes/:code_campagne' do
      let(:question1) { create :question_saisie, transcription_ecrit: 'Ma question' }
      let(:question2) { create :question_clic_dans_image, :avec_images }
      let(:question3) { create :question_glisser_deposer, :avec_images }
      let!(:questionnaire) { create :questionnaire, questions: [ question1, question2, question3 ] }
      let!(:campagne) do
        create :campagne, code: 'ETE21', libelle: 'Ma campagne ete 21'
      end

      before do
        # Bullet ne considère pas l'include de Blob comme nécéssaire, alors qu'il l'est.
        Bullet.add_safelist type: :unused_eager_loading, class_name: 'ActiveStorage::Attachment',
                            association: :blob
      end

      it 'retourne les informations de la campagne' do
        get '/api/campagnes/ete21'

        expect(response).to be_ok
        resultat = response.parsed_body
        expect(resultat['libelle']).to eq('Ma campagne ete 21')
        expect(resultat['code']).to eq('ETE21')
      end

      context "quand on passe l'id de la campagne" do
        it "retourne une 200" do
          get "/api/campagnes/#{campagne.id}"

          expect(response).to have_http_status(:ok)
        end
      end

      context "quand la campagne n'existe pas" do
        it "retourne une 404" do
          code_inconnue = 'INCONNUE'
          get "/api/campagnes/#{code_inconnue}"

          expect(response).to have_http_status(:not_found)
        end
      end

      context "quand la campagne n'est pas active" do
        it "retourne une 403" do
          campagne.update!(active: false)

          get "/api/campagnes/#{campagne.code}"

          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body['error']).to eq(I18n.t("errors.campagne_inactive"))
        end
      end

      context 'quand la campagne a des situations' do
        let(:question_entrainement) do
          create :question_saisie, transcription_ecrit: 'Ma question entrainement'
        end
        let(:questionnaire_entrainement) do
          create :questionnaire,
                 questions: [ question_entrainement ]
        end
        let(:questionnaire_surcharge) {
 create :questionnaire, questions: [ question_entrainement ] }
        let(:situation_bienvenue) do
          create :situation_bienvenue,
                 libelle: 'Bienvenue',
                 questionnaire_entrainement: questionnaire_entrainement,
                 questionnaire: questionnaire
        end
        let(:situation_livraison) do
          create :situation_livraison,
                 libelle: 'Livraison',
                 questionnaire_entrainement: questionnaire_entrainement,
                 questionnaire: questionnaire
        end
        let(:situation_inventaire) { create :situation_inventaire }

        before do
          campagne.situations_configurations.create situation: situation_bienvenue,
                                                    position: 2,
                                                    questionnaire: questionnaire_surcharge
          campagne.situations_configurations.create situation: situation_livraison, position: 1
          campagne.situations_configurations.create situation: situation_inventaire
        end

        it 'retourne les situations de la campagne' do
          get '/api/campagnes/ete21'

          reponse_json = response.parsed_body

          expect(reponse_json['situations'].size).to be(3)
          premiere_situation = reponse_json['situations'][0]
          expect(premiere_situation['libelle']).to eql('Livraison')
          expect(premiere_situation['nom_technique']).to eql('livraison')
          expect(premiere_situation['nom_technique_sans_variant']).to eql('livraison')
          expect(premiere_situation['id']).to eql(situation_livraison.id)
          expect(premiere_situation['questionnaire_id']).to eql(questionnaire.id)
          expect(premiere_situation['questions'][0]['intitule'])
            .to eql('Ma question')
          expect(premiere_situation['questionnaire_entrainement_id'])
            .to eql(questionnaire_entrainement.id)
          expect(premiere_situation['questions_entrainement'][0]['intitule'])
            .to eql('Ma question entrainement')

          seconde_situation = reponse_json['situations'][1]
          expect(seconde_situation['libelle']).to eql('Bienvenue')
          expect(seconde_situation['questionnaire_id'])
            .to eql(questionnaire_surcharge.id)

          troisieme_situation = reponse_json['situations'][2]
          expect(troisieme_situation['libelle']).to eql('Inventaire')
          expect(troisieme_situation['questionnaire_id']).to be_nil
          expect(troisieme_situation['questions']).to be_nil
          expect(troisieme_situation['questionnaire_entrainement_id']).to be_nil
          expect(troisieme_situation['questions_entrainement']).to be_nil
        end
      end

      context 'quand la campagne a un opco financeur' do
        let(:opco_financeur) { create :opco, :constructys }
        let(:structure) { create :structure_locale, opco: opco_financeur }
        let(:compte) { create :compte, structure: structure }
        let(:campagne) { create :campagne, compte: compte, code: 'ETE21' }

        it "retourne l'opco financeur" do
          get '/api/campagnes/ete21'

          expect(response).to have_http_status(:ok)
          resultat = response.parsed_body
          expect(resultat['opco_financeur']['nom']).to eq('Constructys')
        end
      end
    end
  end
end
