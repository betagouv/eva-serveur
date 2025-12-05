class Inscription::StructuresController < ApplicationController
  before_action :set_compte_and_structure

  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    prepare_structure_si_necessaire
  end

  def update
    action_type = determine_action_type

    case action_type
    when "recherche"
      redirige_vers_recherche_structure
    when "rejoindre"
      rejoindre_structure_existante
    when "creer"
      creer_nouvelle_structure
    end
  end

  private

  def set_compte_and_structure
    @compte = current_compte
    @structure = @compte.structure
  end

  def prepare_structure_si_necessaire
    return if @structure.present? || @compte.siret_pro_connect.blank?

    @compte = RechercheStructureParSiret.new(@compte, @compte.siret_pro_connect).call
    @structure = @compte.structure
  end

  def determine_action_type
    params.dig(:structure_locale, :action_type) ||
      params.dig(:structure, :action_type) ||
      params[:action_type]
  end

  def redirige_vers_recherche_structure
    @compte.update(structure_id: nil, etape_inscription: :recherche_structure)
    redirige_vers_etape_inscription(@compte)
  end

  def rejoindre_structure_existante
    if @compte.update(etape_inscription: :complet)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  def creer_nouvelle_structure
    resultat = CreeStructureProConnect.new(@compte, structure_params).call

    if resultat[:success]
      @compte = resultat[:compte]
      redirige_vers_etape_inscription(@compte)
    else
      @structure = resultat[:structure]
      render :show
    end
  end

  def structure_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.require(param_key).permit(:nom, :type_structure)
  end
end
