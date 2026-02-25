class Inscription::RechercheStructuresController < ApplicationController
  before_action :set_compte, :verifie_compte_connecte, :verifie_etape_inscription

  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
  end

  def update
    valide_siret_et_remplir_erreurs
    if @compte.errors[:siret_pro_connect].present?
      render :show
      return
    end
    if assigne_siret_pour_compte(@compte.siret_pro_connect)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  private

  def valide_siret_et_remplir_erreurs
    siret = siret_param.to_s.strip
    @compte.siret_pro_connect = siret
    if siret.blank?
      @compte.errors.add(:siret_pro_connect, :invalid)
    else
      @compte.validate_siret_format
    end
  end

  def set_compte
    @compte = current_compte
  end

  def verifie_etape_inscription
    return if @compte&.etape_inscription == "recherche_structure"

    redirect_to admin_dashboard_path
  end

  def siret_param
    params[:compte]&.dig(:siret_pro_connect).presence || params[:siret]
  end

  def assigne_siret_pour_compte(siret)
    structure = RechercheStructureParSiret.new(siret).call

    return false if structure.blank?

    # Structure temporaire rejetee par l'API Sirene : erreur sur le champ
    # a cette etape au lieu de laisser l'utilisateur arriver sur "Creer la structure".
    if structure.new_record? && structure.statut_siret == false
      siret_ferme = structure.respond_to?(:siret_ferme) && structure.siret_ferme
      erreur = siret_ferme ? :siret_ferme : :invalid
      @compte.errors.add(:siret_pro_connect, erreur)
      return false
    end

    @compte.siret_pro_connect = siret
    @compte.etape_inscription = :assignation_structure
    @compte.save
  end
end
