require 'rails_helper'

describe ProConnectHelper do
  describe '#logout' do
    it "construit l'url de deconnexion et nettoie la session" do
      stub_const('::ProConnectHelper::PC_BASE_URL', 'https://PC_HOST')
      session = {
        pc_state: 'STATE',
        pc_logout_token: 'TOKEN'
      }
      expect(described_class.logout(session, 'https://post_logout_uri'))
        .to eq('https://PC_HOST/api/v2/session/end?id_token_hint=TOKEN&post_logout_redirect_uri=https%3A%2F%2Fpost_logout_uri&state=STATE')
      expect(session[:pc_logout_token]).to be_nil
    end
  end
end
