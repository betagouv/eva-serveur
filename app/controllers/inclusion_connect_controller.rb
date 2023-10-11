# frozen_string_literal: true

class InclusionConnectController < ApplicationController
  def auth
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
    redirect_to InclusionConnectHelper.auth_path(session[:ic_state],
                                                 inclusion_connect_callback_url),
                allow_other_host: true
  end

  def callback
    tokens = correct_state? &&
             InclusionConnectHelper.recupere_tokens(params[:code], inclusion_connect_callback_url)
    compte = tokens && InclusionConnectHelper.compte(tokens['access_token'])
    echec_login and return if compte.blank?

    session[:ic_logout_token] = tokens['id_token']
    sign_in_and_redirect compte, scope: :compte
  end

  def logout
    if session[:ic_state].blank? || session[:ic_logout_token].blank?
      redirect_to destroy_compte_session_url and return
    end

    sign_out(current_compte)
    redirect_to InclusionConnectHelper.logout(session, destroy_compte_session_url),
                allow_other_host: true
  end

  private

  def echec_login
    flash[:error] = I18n.t('.inclusion-connect.authentification-impossible',
                           email_contact: Eva::EMAIL_SUPPORT)
    redirect_to new_compte_session_path
  end

  def correct_state?
    params[:state] == session[:ic_state]
  end
end
