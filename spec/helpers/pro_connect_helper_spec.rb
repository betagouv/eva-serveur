# frozen_string_literal: true

require 'rails_helper'

describe ProConnectHelper do
  let(:email) { 'toto@eva.beta.gouv.fr' }
  let(:ancien_email) { 'autre@eva.beta.gouv.fr' }
  let(:aujourdhui) { Time.zone.local(2023, 1, 10, 12, 0, 0) }
  let(:hier) { Time.zone.local(2023, 1, 9, 12, 0, 0) }

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
