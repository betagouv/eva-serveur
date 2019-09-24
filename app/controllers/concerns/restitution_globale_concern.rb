# frozen_string_literal: true

module RestitutionGlobaleConcern
  extend ActiveSupport::Concern

  def restitutions
    Evenement.where(nom: 'demarrage', evaluation_id: params[:id])
  end

  def restitutions_selectionnees_ids
    return if restitutions.blank?

    params[:restitutions_selectionnees] ||= restitutions.collect { |r| r.id.to_s }
    params[:restitutions_selectionnees]
  end

  def restitution_globale
    return if restitutions_selectionnees_ids.blank?

    evaluation = Evenement.find(restitutions_selectionnees_ids.first).evaluation
    restitutions = restitutions_selectionnees_ids.map do |id|
      FabriqueRestitution.depuis_evenement_id id
    end
    Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
  end
end
