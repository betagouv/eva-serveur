# frozen_string_literal: true

module Eva
  module Devise
    class PasswordsController < ActiveAdmin::Devise::PasswordsController
      # rubocop:disable Rails/LexicallyScopedActionFilter
      before_action :validate_reset_password_token, only: :edit
      # rubocop:enable Rails/LexicallyScopedActionFilter

      private

      def validate_reset_password_token
        token = ::Devise.token_generator.digest(resource_class, :reset_password_token,
                                                params[:reset_password_token])
        recoverable = resource_class.find_by(reset_password_token: token)
        return if recoverable&.reset_password_period_valid?

        flash[:error] = t('active_admin.devise.passwords.edit.token_invalide')
        redirect_to new_compte_password_path(token_invalide: true)
      end
    end
  end
end
