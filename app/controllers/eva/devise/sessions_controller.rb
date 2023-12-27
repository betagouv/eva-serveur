# frozen_string_literal: true

module Eva
  module Devise
    class SessionsController < ActiveAdmin::Devise::SessionsController
      before_action :check_compte_confirmation, only: :create
      before_action :valide_robustesse_mot_de_de_passe, only: :create

      def create
        self.resource = warden.authenticate!(auth_options)
        assigne_message_flash resource
        sign_in(resource_name, resource)
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource)
      end

      def connexion_espace_jeu
        code = params[:code].upcase
        campagne = Campagne.par_code(code)
        if campagne.present?
          params_url = { code: code }
          url = "#{URL_CLIENT}?#{params_url.to_query}"
          redirect_to url
        else
          code_erreur = t('active_admin.devise.login.evaluations.code_invalide')
          redirect_to new_compte_session_path(code: code, code_erreur: code_erreur)
        end
      end

      private

      def assigne_message_flash(resource)
        if resource.confirmed?
          set_flash_message!(:notice, :signed_in)
        else
          set_flash_message! :alert, :"signed_in_but_#{resource.inactive_message}"
        end
      end

      def check_compte_confirmation
        return unless params.key?(:compte)

        compte = Compte.find_by email: params[:compte][:email].strip
        return if compte.blank?

        redirect_to new_compte_confirmation_path unless compte.active_for_authentication?
      end

      def valide_robustesse_mot_de_de_passe
        return unless params.key?(:compte)

        compte = warden.authenticate!(auth_options)
        return if succes_validation(compte, params[:compte][:password])

        set_flash_message!(:alert, :mot_de_passe_faible)
        token = compte.send(:set_reset_password_token)
        sign_out(compte)
        redirect_to(edit_password_path(:compte, reset_password_token: token))
      end

      def succes_validation(compte, pass)
        !compte.anlci? ||
          PasswordValidator.est_avec_12_maj_min_num_et_symbol?(pass)
      end
    end
  end
end
