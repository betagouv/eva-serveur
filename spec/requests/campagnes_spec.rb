# frozen_string_literal: true

require 'rails_helper'

describe 'Campagne API', type: :request do
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

    context "quand la campagne n'existe pas" do
      it "retourne une 404" do
        code_inconnue = 'INCONNUE'
        get "/api/campagnes/#{code_inconnue}"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "quand la campagne n'est pas active" do
      it "retourne une 404" do
        campagne.update!(active: false)

        get "/api/campagnes/#{campagne.code}"

        expect(response).to have_http_status(:not_found)
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
      let(:questionnaire_surcharge) { create :questionnaire, questions: [ question_entrainement ] }
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
  end
end
