# frozen_string_literal: true

IC_CLIENT_ID = ENV.fetch('INCLUSION_CONNECT_CLIENT_ID', nil)
IC_CLIENT_SECRET = ENV.fetch('INCLUSION_CONNECT_CLIENT_SECRET', nil)
IC_BASE_URL = ENV.fetch('INCLUSION_CONNECT_BASE_URL', nil)

module InclusionConnectHelper
  class << self
    def auth_path(ic_state, callback_url)
      query = {
        response_type: 'code',
        client_id: ::IC_CLIENT_ID,
        redirect_uri: callback_url,
        scope: 'openid email profile',
        state: ic_state,
        nonce: Digest::SHA1.hexdigest('Something to check when it come back ?'),
        from: 'community'
      }
      "#{::IC_BASE_URL}/auth/authorize?#{query.to_query}"
    end

    def logout_confirmed(post_logout_redirect_uri)
      query = {
        client_id: ::IC_CLIENT_ID,
        post_logout_redirect_uri: post_logout_redirect_uri
      }
      "#{::IC_BASE_URL}/auth/logout?#{query.to_query}"
    end

    def logout(session, post_logout_redirect_uri)
      query = {
        state: session[:ic_state],
        id_token_hint: session[:ic_logout_token],
        post_logout_redirect_uri: post_logout_redirect_uri
      }
      session[:ic_logout_token] = nil
      "#{::IC_BASE_URL}/auth/logout?#{query.to_query}"
    end

    def compte(token)
      return false if token.blank?

      user_info = get_user_info(token)
      return false if user_info.blank?

      cree_ou_recupere_compte(user_info)
    end

    def recupere_tokens(code, callback_url)
      data = { grant_type: 'authorization_code',
               client_id: ::IC_CLIENT_ID, client_secret: ::IC_CLIENT_SECRET,
               code: code, redirect_uri: callback_url }

      res = Typhoeus.post(
        URI("#{::IC_BASE_URL}/auth/token/"),
        body: data.to_query,
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      )
      return false unless res.success?

      JSON.parse(res.body)
    end

    def get_user_info(token)
      uri = URI("#{::IC_BASE_URL}/auth/userinfo/")
      uri.query = URI.encode_www_form({ schema: 'openid' })

      res = Typhoeus.get(uri, headers: { 'Authorization' => "Bearer #{token}" })
      return false unless res.success?

      JSON.parse(res.body)
    end

    def cree_ou_recupere_compte(user_info)
      email = user_info['email'].strip.downcase
      compte = Compte.find_by(id_inclusion_connect: user_info['sub'])
      if compte.present? && compte.email != email
        compte = actualise_email_compte_existant(compte, email)
      end
      compte ||= Compte.find_or_create_by(email: email)
      actualise_autres_champs(compte, user_info)
      compte.save!
      compte
    end

    private

    def actualise_email_compte_existant(compte, email)
      compte_existant = Compte.find_by(email: email)
      if compte_existant.present?
        compte.update!(id_inclusion_connect: nil)
        compte = compte_existant
      else
        compte.email = email
        compte.skip_reconfirmation!
        compte.confirmed_at = Time.zone.now
      end
      compte
    end

    def actualise_autres_champs(compte, user_info)
      compte.id_inclusion_connect = user_info['sub']
      compte.prenom = user_info['given_name']
      compte.nom = user_info['family_name']
      compte.password = SecureRandom.uuid if compte.encrypted_password.blank?
      compte.confirmed_at ||= Time.zone.now
    end
  end
end
