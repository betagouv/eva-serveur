class Inscription::InformationsCompteController < ApplicationController
  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers

  def show
    @compte = current_compte
  end

  def update
    @compte = current_compte
    if @compte.update(compte_parametres.merge(etape_inscription: :complet))
      redirect_to admin_recherche_structure_path
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
