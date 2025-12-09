class Inscription::RechercheStructuresController < ApplicationController
  before_action :set_compte
  before_action :verifie_etape_inscription

  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    @siret = params[:siret]
  end

  def update
    if assigne_structure_pour_compte
      redirige_vers_etape_inscription(@compte)
    else
      @siret = params[:siret]
      flash.now[:error] = t(".erreur_structure_non_trouvee")
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

  def assigne_structure_pour_compte
    siret = params[:siret]&.strip

    structure = RechercheStructureParSiret.new(siret).call

    return false if structure.blank?

    @compte.rejoindre_structure(structure)
    @compte.etape_inscription = :assignation_structure
    @compte.save
  end
end
