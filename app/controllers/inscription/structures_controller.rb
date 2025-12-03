class Inscription::StructuresController < ApplicationController
  before_action :set_compte_and_structure

  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
  end

  def update
    path = nil
    compte_params = if params[:action_type] == "recherche"
      { structure_id: nil, etape_inscription: :recherche_structure }
    elsif params[:action_type] == "rejoindre"
      { etape_inscription: :complet }
    end

    if @compte.update(compte_params)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  private

  def set_compte_and_structure
    @compte = current_compte
    @structure = @compte.structure
  end
end
