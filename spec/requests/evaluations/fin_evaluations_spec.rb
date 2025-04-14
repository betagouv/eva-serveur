# frozen_string_literal: true

require 'rails_helper'

describe 'Fin Evaluation API', type: :request do
  describe 'POST /evaluations/:id/fin' do
    let(:campagne) { create :campagne }
    let(:evaluation) { create :evaluation, campagne: campagne }

    let!(:partie) do
      create :partie, evaluation: evaluation, situation: situation_inventaire
    end
    let!(:situation_inventaire) { create :situation_inventaire, libelle: 'Inventaire' }
    let!(:demarrage) { create :evenement_demarrage, partie: partie }

    before { campagne.situations_configurations.create situation: situation_inventaire }

    context 'met à jour la date de fin' do
      before { post "/api/evaluations/#{evaluation.id}/fin" }

      it do
        expect(evaluation.reload.terminee_le).not_to eql(nil)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'une évaluation inexistante' do
      before { post '/api/evaluations/id_inconnu/fin' }

      it do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'retourne aucune compétences avec une évaluation sans compétences identifiées' do
      before { post "/api/evaluations/#{evaluation.id}/fin" }

      it { expect(response.parsed_body['competences_fortes']).to be_empty }
    end

    context 'avec une évaluation avec des compétences identifiées' do
      let!(:saisie) { create(:evenement_saisie_inventaire, :ok, partie: partie) }
      let!(:fin) { create :evenement_fin_situation, partie: partie }

      context 'avec une campagne configurée sans compétences fortes' do
        before do
          campagne.update(affiche_competences_fortes: false)
          post "/api/evaluations/#{evaluation.id}/fin"
        end

        it { expect(response.parsed_body['competences_fortes']).to be_empty }
      end

      context 'avec une campagne configurée avec compétences fortes' do
        before { post "/api/evaluations/#{evaluation.id}/fin" }

        it 'retourne les compétences triées par ordre de force décroissante' do
          attendues = [ Competence::RAPIDITE, Competence::VIGILANCE_CONTROLE,
                       Competence::ORGANISATION_METHODE ].map(&:to_s)
          expect(response.parsed_body['competences_fortes'].pluck('nom_technique'))
            .to eql(attendues)
        end

        it 'envoie aussi le nom et la description des compétences' do
          premiere_competence = response.parsed_body['competences_fortes'][0]
          expect(premiere_competence['nom']).to eql("Vitesse d'exécution")
          expect(premiere_competence['description'])
            .to eql(I18n.t("#{Competence::RAPIDITE}.description",
                           scope: 'admin.evaluations.restitution_competence'))
          expect(premiere_competence['description']).not_to start_with('translation missing')
        end

        it "envoie aussi l'URL du picto des compétences" do
          premiere_competence = response.parsed_body['competences_fortes'][0]
          expect(premiere_competence['picto'])
            .to start_with('http://asset_host:port/assets/rapidite')
        end
      end
    end
  end
end
