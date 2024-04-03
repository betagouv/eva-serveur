# frozen_string_literal: true

# rubocop:disable Rails/ApplicationController
class ErreursController < ActionController::Base
  # rubocop:enable Rails/ApplicationController
  helper ::ActiveAdmin::ViewHelpers

  def not_found
    render 'erreur', formats: :html, status: :not_found
  end

  def internal_serveur_error
    render 'erreur', formats: :html, status: :internal_server_error
  end

  def unprocessable_entity
    render 'erreur', formats: :html, status: :unprocessable_entity
  end
end
