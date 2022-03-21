# frozen_string_literal: true

class StructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def index
    @structures = StructureLocale.near("#{params[:code_postal]}, FRANCE")
  end

  def show
    structure = Structure.find params[:id]
    redirect_to send("admin_#{structure.type.underscore}_url", structure),
                status: :moved_permanently
  end
end
