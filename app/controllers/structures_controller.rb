# frozen_string_literal: true

class StructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def index
    @structures = Structure.where(code_postal: params[:code_postal])
  end
end
