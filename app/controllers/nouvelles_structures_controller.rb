# frozen_string_literal: true

class NouvellesStructuresController < ApplicationController
  def show
    @campagne = Campagne.new
    compte = @campagne.build_compte
    compte.build_structure
  end

  def create
    @campagne = Campagne.new campagne_parametres
    if @campagne.save
      redirect_to admin_campagne_path(@campagne)
    else
      render :show
    end
  end

  private

  def campagne_parametres
    params.require(:campagne).permit!
  end
end
