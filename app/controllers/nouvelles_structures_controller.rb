# frozen_string_literal: true

class NouvellesStructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def show
    @campagne = Campagne.new
    compte = @campagne.build_compte
    compte.build_structure
  end

  def create
    @campagne = Campagne.new campagne_parametres
    if @campagne.save
      CompteMailer.with(campagne: @campagne).nouveau_compte.deliver_later
      sign_in @campagne.compte
      redirect_to admin_dashboard_path, notice: I18n.t('nouvelle_structure.bienvenue')
    else
      render :show
    end
  end

  private

  def campagne_parametres
    parametres = params.require(:campagne).permit!.to_h
    parametres.deep_merge(initialise_situations: true,
                          compte_attributes: { statut_validation: :acceptee })
  end
end
