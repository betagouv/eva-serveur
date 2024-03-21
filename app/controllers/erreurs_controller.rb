# frozen_string_literal: true

class ErreursController < ApplicationController
  layout 'erreurs'
  helper ::ActiveAdmin::ViewHelpers

  def not_found
    render '404', status: :not_found
  end
end
