# frozen_string_literal: true

require 'rails_helper'
OmniAuth.config.test_mode = true
ENV['GITHUB_ORG'] = 'evaorg'
ENV['GITHUB_TEAM'] = 'evateam'

describe "Authentification avec omniauth dans l'admin", type: :request do
  describe 'GET /admin/auth/github' do
    let(:access_token) { double }
    let(:response) { double }

    def fait_partie_de_equipe_github!
      expect(response).to receive(:status).and_return(200)
      expect(response).to receive(:parsed).and_return('state' => 'active')
    end

    def ne_fait_partie_de_equipe_github!
      expect(response).to receive(:status).and_return(404)
    end

    before do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: 'github',
        uid: '12345',
        credentials: {
          token: 'testtoken'
        },
        info: {
          email: 'test@beta.gouv.fr',
          nickname: 'testnickname'
        }
      )
      expect(OAuth2::AccessToken).to receive(:from_hash).and_return(access_token)
      expect(access_token).to receive(:get)
        .with('/orgs/evaorg/teams/evateam/memberships/testnickname')
        .and_return(response)
    end

    context "lorsque la personne fait partie de l'équipe github" do
      before { fait_partie_de_equipe_github! }

      it 'crée un compte administrateur' do
        expect do
          get '/admin/auth/github'
          follow_redirect!
        end.to change { Compte.count }.by(1)
        compte = Compte.last
        expect(compte.role).to eql('administrateur')
        expect(compte.fournisseur).to eql('github')
        expect(compte.fournisseur_uid).to eql('12345')
        expect(compte.email).to eql('test@beta.gouv.fr')
      end

      context 'avec un utilisateur existant' do
        let!(:compte) { create :compte, email: 'test@beta.gouv.fr', role: 'organisation' }

        it "remplis le fournisseur, l'uid et le role" do
          expect do
            get '/admin/auth/github'
            follow_redirect!
          end.to_not(change { compte.reload.encrypted_password })
          compte.reload
          expect(compte.fournisseur).to eql('github')
          expect(compte.fournisseur_uid).to eql('12345')
          expect(compte.role).to eql('administrateur')
        end
      end
    end

    context "lorsque la personne ne fait pas partie de l'équipe github" do
      before { ne_fait_partie_de_equipe_github! }

      it 'ne crée pas de compte' do
        expect do
          get '/admin/auth/github'
          follow_redirect!
        end.to_not(change { Compte.count })
      end
    end
  end
end
