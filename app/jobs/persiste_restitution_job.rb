# frozen_string_literal: true

class PersisteRestitutionJob < ApplicationJob
  queue_as :default

  def perform(evaluation)
    FabriqueRestitution.restitution_globale(evaluation).persiste
  end
end
