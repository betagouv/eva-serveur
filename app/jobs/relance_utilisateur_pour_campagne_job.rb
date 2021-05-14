# frozen_string_literal: true

class RelanceUtilisateurPourCampagneJob < ApplicationJob
  queue_as :default

  def perform(campagne:)
    return unless campagne.nombre_evaluations.zero?

    CampagneMailer.with(campagne: campagne).relance.deliver_now
  end
end
