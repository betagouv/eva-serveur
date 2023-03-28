# frozen_string_literal: true

class RelanceUtilisateurPourNonActivationJob < ApplicationJob
  queue_as :default

  def perform(compte_id)
    compte = Compte.find_by id: compte_id
    return if compte.blank?

    campagnes = Campagne.avec_nombre_evaluations_et_derniere_evaluation.where(compte: compte)
    return unless campagnes.map(&:nombre_evaluations).reduce(:+).to_i.zero?

    CompteMailer.with(compte: compte).relance.deliver_now
  end
end
