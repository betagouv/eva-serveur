# frozen_string_literal: true

class StructuresController < ApplicationController
  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers

  def index
    @recherche_structure_component = RechercheStructureComponent.new(
      recherche_url: "structures",
      ville_ou_code_postal: params[:ville_ou_code_postal],
      code_postal: params[:code_postal]
    )
  end

  def show
    structure = Structure.find params[:id]
    redirect_to send("admin_#{structure.type.underscore}_url", structure),
                status: :moved_permanently
  end
end
