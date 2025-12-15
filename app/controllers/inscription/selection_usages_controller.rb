class Inscription::SelectionUsagesController < ApplicationController
  before_action :set_compte
  before_action :verifie_etape_inscription

  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    @compte = current_compte
  end

  def update
    @compte = current_compte
    if @compte.update(compte_parametres)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  private

  def set_compte
    @compte = current_compte
  end

  def verifie_etape_inscription
    return if @compte&.etape_inscription == "recherche_structure"

    redirect_to admin_dashboard_path
  end

  def compte_parametres
    permitted_params = params.require(:compte).permit(:usage)

    permitted_params[:etape_inscription] = if @compte.siret_pro_connect.blank?
      "recherche_structure"
    else
      "assignation_structure"
    end
    permitted_params
  end
end
