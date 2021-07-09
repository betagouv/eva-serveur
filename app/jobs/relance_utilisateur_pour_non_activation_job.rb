# frozen_string_literal: true

class RelanceUtilisateurPourNonActivationJob < ApplicationJob
  queue_as :default

  def perform(compte_id)
    compte = Compte.find_by id: compte_id
    return if compte.blank?
    return unless Campagne.where(compte: compte).sum(:nombre_evaluations).zero?

    CompteMailer.with(compte: compte).relance.deliver_now
  end
end
