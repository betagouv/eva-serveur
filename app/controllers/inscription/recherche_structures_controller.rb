class Inscription::RechercheStructuresController < ApplicationController
  before_action :set_compte
  before_action :verifie_etape_inscription

  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    @siret = params[:siret]
  end

  def update
    siret = params[:siret]&.strip

    if siret.blank?
      @siret = siret
      flash.now[:error] = t(".erreur_siret_obligatoire")
      render :show
      return
    end

    # Retire les espaces du SIRET
    siret = siret.gsub(/[[:space:]]/, "")

    # Valide le format (14 chiffres)
    unless siret.match?(/\A\d{14}\z/)
      @siret = params[:siret]
      flash.now[:error] = t(".erreur_siret_invalide")
      render :show
      return
    end

    structure = RechercheStructureParSiret.new(siret).call

    if structure.present?
      @compte.structure = structure
      @compte.assigne_role_admin_si_pas_d_admin
      @compte.etape_inscription = :assignation_structure
      if @compte.save
        redirige_vers_etape_inscription(@compte)
      else
        @siret = params[:siret]
        flash.now[:error] = t(".erreur_generique")
        render :show
      end
    else
      @siret = params[:siret]
      flash.now[:error] = t(".erreur_structure_non_trouvee")
      render :show
    end
  rescue StandardError => e
    Rails.logger.error("Erreur lors de la recherche de structure par SIRET: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @siret = params[:siret]
    flash.now[:error] = t(".erreur_generique")
    render :show
  end

  private

  def set_compte
    @compte = current_compte
  end

  def verifie_etape_inscription
    return if @compte&.etape_inscription == "recherche_structure"

    redirect_to admin_dashboard_path
  end
end

