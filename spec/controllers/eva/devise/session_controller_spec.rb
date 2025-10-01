require 'rails_helper'

describe Eva::Devise::SessionsController, type: :controller do
  let!(:compte) { create :compte_admin }
  let!(:campagne) { create :campagne, compte: compte, code: 'CODECAMPAGNE' }

  describe 'POST connexion_espace_jeu' do
    context 'quand on passe un code campagne valide' do
      it "redirige vers l'espace jeu" do
        params = {
          code: 'codecampagne'
        }

        allow(controller).to receive(:url_campagne)
          .with('CODECAMPAGNE')
          .and_return('URL_CAMPAGNE')

        @request.env['devise.mapping'] = Devise.mappings[:compte]
        post :connexion_espace_jeu, params: params
        expect(response).to redirect_to('URL_CAMPAGNE')
      end
    end

    context 'retourne vers la pae de login' do
      it 'quand on ne passe pas de code campagne' do
        @request.env['devise.mapping'] = Devise.mappings[:compte]
        post :connexion_espace_jeu, params: {}
        expect(response).to redirect_to(
          new_compte_session_path(
            code_erreur: I18n.t('active_admin.devise.login.evaluations.code_invalide')
          )
        )
      end

      it 'quand on passe un code campagne vide' do
        @request.env['devise.mapping'] = Devise.mappings[:compte]
        post :connexion_espace_jeu, params: {
          code: ''
        }
        expect(response).to redirect_to(
          new_compte_session_path(
            code: '',
            code_erreur: I18n.t('active_admin.devise.login.evaluations.code_invalide')
          )
        )
      end
    end
  end
end
