class DemoController < ApplicationController
  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers

  def connect
    echec_captcha and return unless verify_recaptcha

    compte = Compte.find_by(email: Eva::EMAIL_DEMO)
    echec_login and return if compte.blank?

    ConnexionDemo.create
    sign_in_and_redirect compte, scope: :compte
  end

  def echec_login
    flash[:error] = I18n.t(".demo.show.connexion_impossible")
    redirect_to new_compte_session_path
  end

  def echec_captcha
    redirect_to demo_path
  end
end
