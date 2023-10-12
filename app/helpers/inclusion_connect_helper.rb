# frozen_string_literal: true

module InclusionConnectHelper
  IC_CLIENT_ID = ENV.fetch('INCLUSION_CONNECT_CLIENT_ID', nil)
  IC_CLIENT_SECRET = ENV.fetch('INCLUSION_CONNECT_CLIENT_SECRET', nil)
  IC_BASE_URL = ENV.fetch('INCLUSION_CONNECT_BASE_URL', nil)

  class << self
    def auth_path(ic_state, callback_url)
      query = {
        response_type: 'code',
        client_id: IC_CLIENT_ID,
        redirect_uri: callback_url,
        scope: 'openid email profile',
        state: ic_state,
        nonce: Digest::SHA1.hexdigest('Something to check when it come back ?'),
        from: 'community'
      }
      "#{IC_BASE_URL}/auth/authorize?#{query.to_query}"
    end

    def compte(code, callback_url)
      token = get_token(code, callback_url)
      return false if token.blank?

      user_info = get_user_info(token)
      return false if user_info.blank?

      get_and_update_compte(user_info)
    end

    def get_token(code, callback_url)
      data = {
        grant_type: 'authorization_code',
        redirect_uri: callback_url,
        client_id: IC_CLIENT_ID,
        client_secret: IC_CLIENT_SECRET,
        code: code
      }
      uri = URI("#{IC_BASE_URL}/auth/token/")

      res = Typhoeus.post(
        uri,
        body: data.to_query,
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      )
      return false unless res.success?

      JSON.parse(res.body)['access_token']
    end

    def get_user_info(token)
      uri = URI("#{IC_BASE_URL}/auth/userinfo/")
      uri.query = URI.encode_www_form({ schema: 'openid' })

      res = Typhoeus.get(uri, headers: { 'Authorization' => "Bearer #{token}" })
      return false unless res.success?

      JSON.parse(res.body)
    end

    def get_and_update_compte(user_info)
      compte = Compte.find_by(email: user_info['email'])
      return if compte.blank?

      confirmed_at = compte.confirmed_at || Time.zone.now
      compte.update!(
        prenom: user_info['given_name'],
        nom: user_info['family_name'],
        confirmed_at: Time.zone.now,
        last_sign_in_at: Time.zone.now
      )
      compte
    end
  end
end
