# frozen_string_literal: true

class StructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def index
    return if params[:ville_ou_code_postal].blank?

    @structures_code_postal = StructureLocale.where(code_postal: params[:code_postal])
    @structures = StructureLocale.near("#{params[:ville_ou_code_postal]}, FRANCE")
                                 .where.not(id: @structures_code_postal)
  end

  def show
    structure = Structure.find params[:id]
    redirect_to send("admin_#{structure.type.underscore}_url", structure),
                status: :moved_permanently
  end
end
