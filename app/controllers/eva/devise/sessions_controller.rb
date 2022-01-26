# frozen_string_literal: true

module Eva
  module Devise
    class SessionsController < ActiveAdmin::Devise::SessionsController
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
    end
  end
end
