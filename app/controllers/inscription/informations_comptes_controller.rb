class Inscription::InformationsComptesController < ApplicationController
  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    @compte = current_compte
  end

  def update
    @compte = current_compte
    @compte.termine_preinscription!
    if @compte.update(compte_parametres)
      redirige_vers_etape_inscription(@compte)
    else
      render :show
    end
  end

  private

  def compte_parametres
    parametres = params.require(:compte).permit(:nom, :prenom, :email, :fonction,
:service_departement, :cgu_acceptees)
  end
end
