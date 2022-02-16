# frozen_string_literal: true

class NouvellesStructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def show
    @compte = Compte.new
    @compte.build_structure type: StructureLocale.name
  end

  def create
    @compte = Compte.new compte_parametres
    if @compte.save!
      envoie_emails
      sign_in @compte
      redirect_to admin_dashboard_path, notice: I18n.t('nouvelle_structure.bienvenue')
    else
      render :show
    end
  end

  private

  def compte_parametres
    parametres = params.require(:compte).permit!.to_h
    parametres.merge!(statut_validation: :acceptee, role: 'admin')
    parametres[:structure_attributes].merge!(type: StructureLocale.name)
    parametres
  end

  def envoie_emails
    StructureMailer.with(compte: @compte, structure: @compte.structure)
                   .nouvelle_structure
                   .deliver_later
  end
end
