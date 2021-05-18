# frozen_string_literal: true

class RelanceUtilisateurPourNonActivationJob < ApplicationJob
  queue_as :default

  def perform(compte:)
    return unless Campagne.where(compte: compte).sum(:nombre_evaluations).zero?

    CompteMailer.with(compte: compte).relance.deliver_now
  end
end
