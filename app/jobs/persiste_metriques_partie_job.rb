# frozen_string_literal: true

class PersisteMetriquesPartieJob < ApplicationJob
  queue_as :default

  def perform(partie)
    restitution = FabriqueRestitution.instancie partie
    restitution.persiste
  end
end
