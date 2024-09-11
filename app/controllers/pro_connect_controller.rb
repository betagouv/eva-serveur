# frozen_string_literal: true

class ProConnectController < ApplicationController
  def auth
    session[:pc_state] = Digest::SHA256.hexdigest("ProConnect - #{SecureRandom.hex(32)}")
    session[:pc_nonce] = Digest::SHA256.hexdigest("ProConnect - #{SecureRandom.hex(32)}")
    redirect_to ProConnectHelper.auth_path(session[:pc_state], session[:pc_nonce],
                                           pro_connect_callback_url),
                allow_other_host: true
  end

  def callback
    tokens = correct_state? &&
             ProConnectHelper.recupere_tokens(params[:code], pro_connect_callback_url)
    compte = lit_tokens(tokens)
    echec_login and return if compte.blank?

    session[:pc_logout_token] = tokens['id_token']
    sign_in_and_redirect compte, scope: :compte
  end

  def lit_tokens(tokens)
    tokens &&
      ProConnectHelper.verifie(tokens['id_token'], session[:pc_nonce]) &&
      ProConnectHelper.compte(tokens['access_token'])
  end

  def logout
    if session[:pc_state].blank? || session[:pc_logout_token].blank?
      redirect_to destroy_compte_session_url and return
    end

    sign_out current_compte
    redirect_to ProConnectHelper.logout(session, destroy_compte_session_url),
                allow_other_host: true
  end

  private

  def echec_login
    flash[:error] = I18n.t('.pro-connect.authentification-impossible',
                           email_contact: Eva::EMAIL_SUPPORT)
    redirect_to new_compte_session_path
  end

  def correct_state?
    params[:state] == session[:pc_state]
  end
end
