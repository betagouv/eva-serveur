class Inscription::StructuresController < ApplicationController
  before_action :set_compte_and_structure, :verifie_compte_connecte
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
    @structure = @compte&.structure
  end

  def prepare_structure_si_necessaire
    return if @structure.present? || @compte.siret_pro_connect.blank?

    @structure = RechercheStructureParSiret.new(@compte.siret_pro_connect).call
    AffiliationOpcoService.new(@structure).affilie_opcos if @structure.present?
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
    prepare_structure_si_necessaire
    if @compte.update(etape_inscription: :complet)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  def creer_nouvelle_structure
    ActiveRecord::Base.transaction do
      @structure = cree_structure_avec_params
      return render :show if @structure.blank?

      AffiliationOpcoService.new(@structure).affilie_opcos

      associe_opcos_si_present
      finalise_inscription_compte
    end
  end

  def cree_structure_avec_params
    FabriqueStructure.cree_depuis_siret(
      @compte.siret_pro_connect,
      structure_params.merge(usage: @compte.usage).compact
    )
  end

  def associe_opcos_si_present
    return unless opco_ids_params.present?

    @structure.opco_ids = opco_ids_params
    @structure.save
  end

  def finalise_inscription_compte
    @compte.rejoindre_structure(@structure)
    @compte.etape_inscription = :complet

    if @compte.save
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  def structure_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.require(param_key).permit(:nom, :type_structure)
  end

  def opco_ids_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.dig(param_key, :opco_ids)&.reject(&:blank?)
  end
end
