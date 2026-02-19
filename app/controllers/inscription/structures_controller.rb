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
    when "confirmer_infos", "Confirmer"
      confirme_infos_structure
    when "creer", "Créer la structure", "Confirmer la création"
      creer_nouvelle_structure
    end
  end

  private

  def set_compte_and_structure
    @compte = current_compte
    @structure = @compte&.structure
  end

  def prepare_structure_si_necessaire
    return if @compte.siret_pro_connect.blank?

    recherche_et_assigne_structure
    affilie_et_prepare_opcos
  end

  def recherche_et_assigne_structure
    return if @structure.present?

    @structure = RechercheStructureParSiret.new(@compte.siret_pro_connect).call
    @compte.structure = @structure
  end

  def affilie_et_prepare_opcos
    return unless @structure.present?

    AffiliationOpcoService.new(@structure).affilie_opcos
    assigne_opco_ids_pour_formulaire unless @structure.persisted?
  end

  def assigne_opco_ids_pour_formulaire
    # AffiliationOpcoService a déjà pré-rempli @structure.opco_id quand un seul OPCO est trouvé
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

  def confirme_infos_structure
    if structure_confirmee_params == "1"
      redirect_to inscription_structure_path(etape: "parametrage")
    else
      @structure.errors.add(:structure_confirmee, :must_be_checked)
      render :show
    end
  end

  def creer_nouvelle_structure
    ActiveRecord::Base.transaction do
      @structure = cree_structure_avec_params
      return render_parametrage if @structure.blank?

      @structure.affecte_usage_entreprise_si_necessaire if @structure.is_a?(StructureLocale)

      AffiliationOpcoService.new(@structure).affilie_opcos

      associe_opcos_si_present
      finalise_inscription_compte
    end
  end

  def cree_structure_avec_params
    FabriqueStructure.cree_depuis_siret(
      @compte.siret_pro_connect,
      structure_params.merge(usage: @compte.usage).compact,
      validation_inscription: true
    )
  end

  def associe_opcos_si_present
    return unless opco_id_params.present?

    @structure.validation_inscription = true
    @structure.opco_id = opco_id_params
    @structure.save
  end

  def finalise_inscription_compte
    @compte.rejoindre_structure(@structure)
    @compte.etape_inscription = :complet

    if @compte.save
      CampagneCreateur.new(@structure, @compte).cree_campagne_opco! if @structure.eva_entreprises?
      redirige_vers_etape_inscription(@compte)
    else
      render_parametrage
    end
  end

  def structure_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.require(param_key).permit(:nom, :type_structure, :opco_id)
  end

  def opco_id_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.dig(param_key, :opco_id)&.presence
  end

  def structure_confirmee_params
    param_key = params[:structure].present? ? :structure : :structure_locale
    params.dig(param_key, :structure_confirmee)
  end

  def render_parametrage
    params[:etape] = "parametrage"
    render :show
  end
end
