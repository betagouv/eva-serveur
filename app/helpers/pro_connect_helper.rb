# frozen_string_literal: true

module ProConnectHelper
  PC_CLIENT_ID = ENV.fetch('PRO_CONNECT_CLIENT_ID', nil)
  PC_CLIENT_SECRET = ENV.fetch('PRO_CONNECT_CLIENT_SECRET', nil)
  PC_BASE_URL = ENV.fetch('PRO_CONNECT_BASE_URL', nil)

  class << self
    def auth_path(pc_state, pc_nonce, callback_url)
      query = {
        response_type: 'code',
        client_id: PC_CLIENT_ID,
        redirect_uri: callback_url,
        acr_values: 'eidas1',
        scope: 'openid email usual_name given_name',
        state: pc_state,
        nonce: pc_nonce
      }
      "#{PC_BASE_URL}/api/v2/authorize?#{query.to_query}"
    end

    def logout_confirmed(post_logout_redirect_uri)
      query = {
        client_id: PC_CLIENT_ID,
        post_logout_redirect_uri: post_logout_redirect_uri
      }
      "#{PC_BASE_URL}/api/v2/session/end?#{query.to_query}"
    end

    def logout(session, post_logout_redirect_uri)
      query = {
        state: session[:pc_state],
        id_token_hint: session[:pc_logout_token],
        post_logout_redirect_uri: post_logout_redirect_uri
      }
      session[:pc_logout_token] = nil
      "#{PC_BASE_URL}/api/v2/session/end?#{query.to_query}"
    end

    def decode_jwt(jwt)
      decode = JWT.decode(jwt, PC_CLIENT_SECRET, true, { algorithm: 'HS256' })
      yield(decode[0])
    rescue JWT::DecodeError => e
      Rails.logger.warn "erreur JWT: #{e}"
      false
    end

    def verifie(id_token_jwt, nonce)
      decode_jwt(id_token_jwt) { |id_token| id_token['nonce'] == nonce }
    end

    def compte(access_token)
      return false if access_token.blank?

      user_info = get_user_info(access_token)
      return false if user_info.blank?

      cree_ou_recupere_compte(user_info)
    end

    def recupere_tokens(code, callback_url)
      data = { grant_type: 'authorization_code',
               client_id: PC_CLIENT_ID, client_secret: PC_CLIENT_SECRET,
               code: code, redirect_uri: callback_url }

      res = Typhoeus.post(
        URI("#{PC_BASE_URL}/api/v2/token"),
        body: data.to_query,
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      )
      return false unless res.success?

      JSON.parse(res.body)
    end

    def get_user_info(token)
      uri = URI("#{PC_BASE_URL}/api/v2/userinfo")

      res = Typhoeus.get(uri, headers: { 'Authorization' => "Bearer #{token}" })
      return false unless res.success?

      decode_jwt(res.body) { |user_info| user_info }
    end

    def cree_ou_recupere_compte(user_info)
      email = user_info['email'].strip.downcase
      compte = Compte.find_by(id_pro_connect: user_info['sub'])
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
        compte.update!(id_pro_connect: nil)
        compte = compte_existant
      else
        compte.email = email
        compte.skip_reconfirmation!
        compte.confirmed_at = Time.zone.now
      end
      compte
    end

    def actualise_autres_champs(compte, user_info)
      compte.id_pro_connect = user_info['sub']
      compte.prenom = user_info['given_name']
      compte.nom = user_info['usual_name']
      compte.password = SecureRandom.uuid if compte.encrypted_password.blank?
      compte.confirmed_at ||= Time.zone.now
    end
  end
end
