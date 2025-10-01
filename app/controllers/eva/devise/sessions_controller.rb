module Eva
  module Devise
    class SessionsController < ActiveAdmin::Devise::SessionsController
      include CampagneHelper

      before_action :check_compte_confirmation, only: :create

      def create
        self.resource = warden.authenticate!(auth_options)
        return unless est_mot_de_passe_conforme(resource)

        sign_in_avec_message(resource)
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource)
      end

      def connexion_espace_jeu
        code = params[:code]&.upcase
        campagne = code.present? && Campagne.par_code(code)
        if campagne.present?
          redirect_to url_campagne(code), allow_other_host: true
        else
          code_erreur = t("active_admin.devise.login.evaluations.code_invalide")
          redirect_to new_compte_session_path(code: code, code_erreur: code_erreur)
        end
      end

      private

      def sign_in_avec_message(compte)
        if compte.confirmed?
          set_flash_message! :success, :signed_in
        else
          set_flash_message! :alert, :"signed_in_but_#{compte.inactive_message}"
        end
        sign_in(resource_name, compte)
      end

      def check_compte_confirmation
        return unless params.key?(:compte)

        compte = Compte.find_by(email: params[:compte][:email]&.strip)

        return if compte.blank?

        redirect_to new_compte_confirmation_path unless compte.active_for_authentication?
      end

      def est_mot_de_passe_conforme(compte)
        return true unless params.key?(:compte)
        return true if succes_validation_anlci(compte, params[:compte][:password])

        set_flash_message!(:alert, :mot_de_passe_faible)
        compte.send(:set_reset_password_token)
        compte.send_reset_password_instructions
        sign_out(compte)
        redirect_to new_compte_session_path and return false
      end

      def succes_validation_anlci(compte, pass)
        !compte.anlci? ||
          PasswordValidator.est_avec_12_maj_min_num_et_symbol?(pass)
      end
    end
  end
end
