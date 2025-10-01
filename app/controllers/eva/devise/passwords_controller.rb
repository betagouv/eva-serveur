module Eva
  module Devise
    class PasswordsController < ActiveAdmin::Devise::PasswordsController
      # rubocop:disable Rails/LexicallyScopedActionFilter
      before_action :validate_reset_password_token, only: :edit
      before_action :trouve_regles_mot_de_passe, only: :edit
      # rubocop:enable Rails/LexicallyScopedActionFilter

      private

      def trouve_regles_mot_de_passe
        @regles_mot_de_passe = compte&.anlci? ? "regles_mot_de_passe_anlci" : "regles_mot_de_passe"
      end

      def validate_reset_password_token
        return if compte&.reset_password_period_valid?

        flash[:error] = t("active_admin.devise.passwords.edit.token_invalide")
        redirect_to new_compte_password_path(token_invalide: true)
      end

      def compte
        @compte ||= resource_class
                    .find_by(reset_password_token: ::Devise.token_generator.digest(
                      resource_class,
                      :reset_password_token,
                      params[:reset_password_token]
                    ))
      end
    end
  end
end
