# frozen_string_literal: true

class RestitutionGlobaleController < ApplicationController
  def show
    respond_to do |format|
      format.pdf do
        render pdf: evaluation.nom.to_s,
               template: 'admin/restitution_globale/show.pdf.erb',
               layout: 'layouts/pdf_layout',
               locals: { restitution_globale: restitution_globale }
      end
    end
  end

  private

  def restitution_globale
    restitutions = tableau_restitutions_ids.map do |id|
      FabriqueRestitution.depuis_evenement_id id
    end
    Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
  end

  def tableau_restitutions_ids
    params[:restitution_ids].split('-').map(&:to_i)
  end

  def evaluation
    Evenement.find(tableau_restitutions_ids.first).evaluation
  end
end
