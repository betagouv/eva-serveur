# frozen_string_literal: true

class InclusionConnectController < ApplicationController
  def auth
    session[:ic_state] = Digest::SHA1.hexdigest("InclusionConnect - #{SecureRandom.hex(13)}")
    redirect_to InclusionConnectHelper.auth_path(session[:ic_state],
                                                 inclusion_connect_callback_url),
                allow_other_host: true
  end

  def callback
    compte = correct_state? &&
             InclusionConnectHelper.compte(params[:code], inclusion_connect_callback_url)
    if compte.blank?
      flash[:error] = I18n.t('.inclusion-connect.authentification-impossible',
                             email_contact: Eva::EMAIL_SUPPORT)
      redirect_to new_compte_session_path and return
    end

    bypass_sign_in compte, scope: :compte
    session[:connected_with_inclusionconnect] = true
    redirect_to root_path
  end

  def correct_state?
    params[:state] == session[:ic_state]
  end
end
