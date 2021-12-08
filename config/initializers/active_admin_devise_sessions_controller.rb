# frozen_string_literal: true

module ActiveAdmin
  module Devise
    class SessionsController
      before_action :check_compte_confirmation, only: :create

      def create
        self.resource = warden.authenticate!(auth_options)
        assigne_message_flash resource
        sign_in(resource_name, resource)
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource)
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
        compte = Compte.find_by email: params[:compte][:email].strip
        return if compte.blank?

        redirect_to new_compte_confirmation_path unless compte.active_for_authentication?
      end
    end
  end
end
