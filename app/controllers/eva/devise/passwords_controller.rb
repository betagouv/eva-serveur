module Eva
  module Devise
    class PasswordsController < ActiveAdmin::Devise::PasswordsController
      layout "inscription_v2"

      # rubocop:disable Rails/LexicallyScopedActionFilter
      before_action :assign_reset_password_context, only: %i[new edit create update]
      before_action :redirect_si_token_invalide, only: :edit
      # rubocop:enable Rails/LexicallyScopedActionFilter

      private

      def assign_reset_password_context
        reset_password_token = params[:reset_password_token] ||
                               params[resource_name]&.[](:reset_password_token)
        @reset_password = ResetPassword::PageContext.new(
          action_name: action_name,
          token_invalide: params[:token_invalide],
          reset_password_token: reset_password_token,
          resource_class: resource_class
        )
      end

      def redirect_si_token_invalide
        path = @reset_password.redirect_path_si_token_invalide
        redirect_to path if path
      end
    end
  end
end
