class Inscription::NouveauxComptesController < ApplicationController
  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    if current_compte&.doit_completer_inscription?
      redirige_vers_etape_inscription(current_compte)
      return
    end

    if current_compte.present?
      redirect_to admin_dashboard_path
      return
    end

    @compte = Compte.new
  end

  def create
    if current_compte.present?
      redirect_to admin_dashboard_path
      return
    end

    @compte = Compte.new(compte_parametres.merge(role: :conseiller, statut_validation: :en_attente))
    @compte.assigne_preinscription
    if @compte.save
      sign_in(@compte)
      redirect_to inscription_informations_compte_path
    else
      render :show
    end
  end

  private

  def compte_parametres
    params.require(:compte).permit(
      :prenom,
      :nom,
      :telephone,
      :email,
      :password,
      :password_confirmation,
      :fonction,
      :service_departement,
      :cgu_acceptees
    )
  end
end
