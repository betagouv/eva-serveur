class Inscription::StructuresController < ApplicationController
  before_action :set_compte_and_structure

  layout "inscription_v2"
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
    when "creer", "Créer ma structure"
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

    @structure = RechercheStructureParSiret.new(@compte.siret_pro_connect).call
    @compte.structure = @structure
  end

  def determine_action_type
    params[:commit]
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
    @structure = RechercheStructureParSiret.new(@compte.siret_pro_connect).call

    @structure.assign_attributes(structure_params)
    @compte.rejoindre_structure(@structure)
    @compte.etape_inscription = :complet

    if @compte.save && @structure.save
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  def structure_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.require(param_key).permit(:nom, :type_structure)
  end
end
