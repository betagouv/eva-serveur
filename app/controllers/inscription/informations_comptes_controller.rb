class Inscription::InformationsComptesController < ApplicationController
  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper
  before_action :set_compte, :verifie_compte_connecte

  def show
  end

  def update
    @compte.termine_preinscription!
    @compte.assign_attributes(compte_parametres)
    if @compte.save(context: :informations_compte)
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

  def set_compte
    @compte = current_compte
  end
end
